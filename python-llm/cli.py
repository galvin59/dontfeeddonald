"""
Command-line interface for brand lookup operations.

This script provides a CLI for individual brand lookup operations.
"""

import asyncio
import argparse
import logging
import os
from typing import List, Optional
from dotenv import load_dotenv

from app.db_service import get_db_session, get_incomplete_brands
from app.processor import BrandProcessor
from app.models import BrandLiteracy

# Load environment variables
load_dotenv()

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler("brand_cli.log"),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

async def process_brand_by_name(brand_name: str, fields: List[str] = None, model_name: str = "mistral"):
    """
    Process a brand by name.
    
    Args:
        brand_name: Name of the brand to process
        fields: List of fields to process (None for all)
        model_name: LLM model to use
    """
    logger.info(f"Looking up information for brand: {brand_name}")
    
    # Initialize processor
    processor = BrandProcessor(model_name=model_name)
    
    # Get database session
    session = get_db_session()
    
    try:
        # Find the brand in the database
        from sqlalchemy import select
        query = select(BrandLiteracy).where(BrandLiteracy.name == brand_name)
        brand = session.execute(query).scalar_one_or_none()
        
        if not brand:
            logger.error(f"Brand '{brand_name}' not found in the database")
            print(f"Brand '{brand_name}' not found in the database")
            return
        
        # Process requested fields or all fields
        if fields:
            # Validate fields
            valid_fields = set(processor.field_order)
            for field in fields:
                if field not in valid_fields:
                    logger.warning(f"Invalid field: {field}")
                    print(f"Invalid field: {field}. Valid fields are: {', '.join(valid_fields)}")
                    return
            
            # Only process specified fields
            for field in fields:
                print(f"Processing field: {field} for {brand_name}...")
                success = await processor.process_brand_field(brand, field, session)
                if success:
                    value = getattr(brand, field, None)
                    source = getattr(brand, f"{field}Source", None)
                    print(f"✅ {field}: {value}")
                    if source:
                        print(f"📚 Source: {source}")
                else:
                    print(f"❌ Failed to process {field}")
        else:
            # Process all fields in order
            results = await processor.process_brand(brand, session)
            
            # Print results
            print(f"\nResults for {brand_name}:")
            for field, success in results.items():
                if success:
                    value = getattr(brand, field, None)
                    source = getattr(brand, f"{field}Source", None)
                    print(f"✅ {field}: {value}")
                    if source:
                        print(f"📚 Source: {source}")
                else:
                    print(f"❌ Failed to process {field}")
    
    except Exception as e:
        logger.error(f"Error processing brand {brand_name}: {str(e)}")
        print(f"Error: {str(e)}")
    
    finally:
        session.close()

async def list_incomplete_brands(limit: int = 10, field: Optional[str] = None):
    """
    List brands with incomplete information.
    
    Args:
        limit: Maximum number of brands to list
        field: Specific field to check for incompleteness
    """
    session = get_db_session()
    
    try:
        brands = get_incomplete_brands(session, limit=limit, field=field)
        
        if not brands:
            print(f"No brands found with missing {field if field else 'any'} information")
            return
        
        print(f"Brands with missing {field if field else 'any'} information:")
        for brand in brands:
            print(f"- {brand.name} (ID: {brand.id})")
            
            # Print missing fields
            missing_fields = []
            for field_name in BrandProcessor().field_order:
                if getattr(brand, field_name, None) in [None, "", "Unknown"]:
                    missing_fields.append(field_name)
            
            print(f"  Missing fields: {', '.join(missing_fields)}")
    
    except Exception as e:
        logger.error(f"Error listing incomplete brands: {str(e)}")
        print(f"Error: {str(e)}")
    
    finally:
        session.close()

def main():
    """Main entry point for the CLI."""
    parser = argparse.ArgumentParser(description="Brand lookup CLI")
    subparsers = parser.add_subparsers(dest="command", help="Command to run")
    
    # Command to process a specific brand
    process_parser = subparsers.add_parser("process", help="Process a brand")
    process_parser.add_argument("brand_name", help="Name of the brand to process")
    process_parser.add_argument("--fields", nargs="+", help="Fields to process (space-separated)")
    process_parser.add_argument("--model", default="mistral", help="LLM model to use")
    process_parser.add_argument("--env", default="dev", choices=["dev", "test", "prod"], help="Environment to run in")
    
    # Command to list incomplete brands
    list_parser = subparsers.add_parser("list", help="List incomplete brands")
    list_parser.add_argument("--limit", type=int, default=10, help="Maximum number of brands to list")
    list_parser.add_argument("--field", help="Specific field to check for incompleteness")
    list_parser.add_argument("--env", default="dev", choices=["dev", "test", "prod"], help="Environment to run in")
    
    args = parser.parse_args()
    
    # Set environment-specific configurations
    if args.env == "dev":
        os.environ["OPENAI_API_BASE"] = "http://localhost:1234/v1"
        logging.getLogger().setLevel(logging.DEBUG)
    elif args.env == "test":
        os.environ["OPENAI_API_BASE"] = "http://localhost:1234/v1"
        logging.getLogger().setLevel(logging.INFO)
    elif args.env == "prod":
        # In production, use the actual OpenAI API or other configured endpoint
        logging.getLogger().setLevel(logging.INFO)
    
    if args.command == "process":
        asyncio.run(process_brand_by_name(
            brand_name=args.brand_name,
            fields=args.fields,
            model_name=args.model
        ))
    elif args.command == "list":
        asyncio.run(list_incomplete_brands(
            limit=args.limit,
            field=args.field
        ))
    else:
        parser.print_help()

if __name__ == "__main__":
    main()
