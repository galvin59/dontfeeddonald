"""
Main application for brand information lookup.

This script processes brands with missing information and updates the database.
"""

import asyncio
import argparse
import logging
import os
import sys
from datetime import datetime
from dotenv import load_dotenv
from colorama import init, Fore, Style, Back

from app.db_service import get_db_session, get_incomplete_brands
from app.processor import BrandProcessor

# Initialize colorama for cross-platform colored terminal text
init(autoreset=True)

# Load environment variables
load_dotenv()

# Disable logging for specific noisy libraries
logging.getLogger("asyncio").setLevel(logging.WARNING)
logging.getLogger("httpx").setLevel(logging.WARNING)
logging.getLogger("httpcore").setLevel(logging.WARNING)
logging.getLogger("openai").setLevel(logging.WARNING)
logging.getLogger("langchain").setLevel(logging.WARNING)

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(message)s',
    handlers=[
        logging.FileHandler("brand_lookup.log"),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

async def process_brands(batch_size: int = 5, model_name: str = "mistral", temperature: float = 0.1):
    """
    Process brands with missing information and update the database.
    
    Args:
        batch_size: Number of brands to process in one run
        model_name: LLM model to use
        temperature: Temperature for LLM generation
    """
    print(f"{Back.BLUE}{Fore.WHITE} 🚀 STARTING BRAND PROCESSOR {Style.RESET_ALL} "
          f"{Fore.CYAN}Batch size: {Fore.YELLOW}{batch_size}{Fore.CYAN}, "
          f"Model: {Fore.YELLOW}{model_name}{Fore.CYAN}, "
          f"Temp: {Fore.YELLOW}{temperature}{Style.RESET_ALL}")
    
    # Simple log for file
    logger.info(f"Starting brand processing with batch size {batch_size}, model {model_name}")
    
    # Initialize the processor
    processor = BrandProcessor(model_name=model_name, temperature=temperature)
    
    # Get a database session
    session = get_db_session()
    
    fields_to_process = [
        ("parentCompany", "🏢", "Parent company"),
        ("brandOrigin", "🌍", "Brand origin"),
        ("logoUrl", "🖼️", "Logo URL"),
        (None, "📊", "Any missing fields")
    ]
    
    try:
        # Process each field type in sequence
        for field_name, emoji, display_name in fields_to_process:
            print(f"\n{Fore.MAGENTA}{Style.BRIGHT}{emoji} Processing brands with missing {display_name}...{Style.RESET_ALL}")
            
            # Get brands with missing information for this field (or any field)
            brands = get_incomplete_brands(session, limit=batch_size, field=field_name)
            
            if not brands:
                print(f"{Fore.YELLOW}   ℹ️ No brands found with missing {display_name}{Style.RESET_ALL}")
                continue
                
            for brand in brands:
                brand_name_display = f"{Fore.YELLOW}{Style.BRIGHT}{brand.name}{Style.RESET_ALL}"
                print(f"\n{emoji} Processing {display_name} for brand: {brand_name_display}")
                
                # Process the brand
                results = await processor.process_brand(brand, session)
                _log_results(brand.name, results)
        
        print(f"\n{Back.GREEN}{Fore.WHITE} ✨ PROCESSING COMPLETED SUCCESSFULLY {Style.RESET_ALL}")
        logger.info("Brand processing completed successfully")
    
    except KeyboardInterrupt:
        print(f"\n{Back.YELLOW}{Fore.BLACK} ⚠️ PROCESSING INTERRUPTED BY USER {Style.RESET_ALL}")
        logger.warning("Brand processing interrupted by user")
    
    except Exception as e:
        error_msg = str(e)
        print(f"\n{Back.RED}{Fore.WHITE} ❌ ERROR DURING PROCESSING {Style.RESET_ALL}")
        print(f"{Fore.RED}{error_msg}{Style.RESET_ALL}")
        logger.error(f"Error during brand processing: {error_msg}")
    
    finally:
        session.close()
        print(f"{Fore.BLUE}Database session closed{Style.RESET_ALL}")

def _log_results(brand_name: str, results: dict):
    """Log the results of processing a brand with colors and emojis."""
    for field, success in results.items():
        if success:
            log_msg = f"✅ {Fore.GREEN}Successfully processed {Fore.CYAN}{field}{Fore.GREEN} for {Fore.YELLOW}{brand_name}{Style.RESET_ALL}"
            print(log_msg)  # Direct print for colored output
            logger.info(f"✅ Successfully processed {field} for {brand_name}")  # Plain for log file
        else:
            log_msg = f"❌ {Fore.RED}Failed to process {Fore.CYAN}{field}{Fore.RED} for {Fore.YELLOW}{brand_name}{Style.RESET_ALL}"
            print(log_msg)  # Direct print for colored output
            logger.warning(f"❌ Failed to process {field} for {brand_name}")  # Plain for log file

def main():
    """Main entry point for the application."""
    parser = argparse.ArgumentParser(description="Process brand information")
    parser.add_argument("--batch-size", type=int, default=5, help="Number of brands to process")
    parser.add_argument("--model", type=str, default="mistral", help="LLM model to use")
    parser.add_argument("--temperature", type=float, default=0.1, help="Temperature for LLM generation")
    parser.add_argument("--env", type=str, default="dev", choices=["dev", "test", "prod"], help="Environment to run in")
    parser.add_argument("--quiet", action="store_true", help="Reduce output verbosity")
    
    args = parser.parse_args()
    
    # Set environment-specific configurations
    env_colors = {
        "dev": f"{Back.BLUE}{Fore.WHITE}",
        "test": f"{Back.YELLOW}{Fore.BLACK}",
        "prod": f"{Back.RED}{Fore.WHITE}"
    }
    
    print(f"{env_colors[args.env]} ENVIRONMENT: {args.env.upper()} {Style.RESET_ALL}")
    
    if args.env == "dev":
        os.environ["OPENAI_API_BASE"] = "http://localhost:1234/v1"
        if not args.quiet:
            print(f"{Fore.CYAN}Using local LLM at: {Fore.GREEN}http://localhost:1234/v1{Style.RESET_ALL}")
    elif args.env == "test":
        os.environ["OPENAI_API_BASE"] = "http://localhost:1234/v1"
    elif args.env == "prod":
        # In production, use the actual OpenAI API or other configured endpoint
        pass
    
    # Set logging levels based on environment and quiet flag
    if args.quiet:
        # Make libraries even quieter
        logging.getLogger().setLevel(logging.WARNING)
        for lib_logger in ["asyncio", "httpx", "httpcore", "openai", "langchain"]:
            logging.getLogger(lib_logger).setLevel(logging.ERROR)
    
    try:
        # Run the processing
        asyncio.run(process_brands(
            batch_size=args.batch_size,
            model_name=args.model,
            temperature=args.temperature
        ))
    except KeyboardInterrupt:
        print(f"\n{Back.YELLOW}{Fore.BLACK} ⚠️ PROGRAM INTERRUPTED BY USER {Style.RESET_ALL}")
        sys.exit(130)  # Standard exit code for SIGINT

if __name__ == "__main__":
    main()
