"""
Brand information processor.

This module handles processing brand information in sequence.
"""

import asyncio
import json
import logging
from typing import List, Dict, Any, Optional, Tuple

from app.models import BrandLiteracy
from app.agent import BrandLookupAgent
from app.logo_search import search_brand_logo
from app.db_service import update_brand

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler("brand_processor.log"),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

class BrandProcessor:
    """Handles the sequential processing of brand information."""
    
    # Define the order of fields to process
    # Note: logoUrl is handled separately in process_brand_field
    FIELD_ORDER = [
        "parentCompany",
        "brandOrigin", 
        # "logoUrl", # Handled separately
        "productFamily", # Added as it exists in model and prompts
        "usEmployees",
        "euEmployees",
        "usFactory",
        "euFactory",
        "usSupplier",
        "euSupplier"
    ]
    
    BOOLEAN_FIELDS = {
        "usEmployees",
        "euEmployees",
        "usFactory",
        "euFactory",
        "usSupplier",
        "euSupplier"
    }
    
    def __init__(self, model_name: str = "mistral", temperature: float = 0.1):
        """
        Initialize the brand processor.
        
        Args:
            model_name: LLM model to use
            temperature: Temperature for LLM generation
        """
        self.agent = BrandLookupAgent(model_name=model_name, temperature=temperature)
        self.field_order = self.FIELD_ORDER # Use class variable
        logger.info(f"Initialized BrandProcessor with {model_name} model")
        
    async def process_brand_field(self, brand: BrandLiteracy, field: str, session) -> bool:
        """
        Process a specific field for a brand.
        
        Args:
            brand: BrandLiteracy object to process
            field: Field to process
            session: Database session
            
        Returns:
            True if successful, False otherwise
        """
        logger.info(f"Processing field '{field}' for brand '{brand.name}'")
        
        try:
            # Handle logo URL separately as it doesn't use the agent
            if field == "logoUrl":
                result = search_brand_logo(brand)
                if result and "logo_url" in result and result["logo_url"] and result["logo_url"].get("value"):
                    logo_url = result["logo_url"]["value"]
                    source = result["logo_url"].get("source", "")
                    logger.info(f"Found logo URL for {brand.name}: {logo_url}")
                    return update_brand(session, brand.id, field, logo_url, source)
                else:
                    logger.warning(f"No logo URL found for {brand.name}")
                    return False
            
            # Use the agent for all other fields
            result = await self.agent.lookup_field(brand, field)
            
            # Extract the value and source from the result
            value_source = self._extract_value_and_source(result, field)
            
            if value_source:
                value, source = value_source
                logger.info(f"Found {field} for {brand.name}: {value}")
                return update_brand(session, brand.id, field, value, source)
            else:
                logger.warning(f"No {field} information found for {brand.name}")
                return False
                
        except Exception as e:
            logger.error(f"Error processing {field} for {brand.name}: {str(e)}")
            return False
    
    def _extract_value_and_source(self, result, field: str) -> Optional[Tuple[Any, str]]:
        """
        Extract value and source from agent result.
        
        Args:
            result: Result from agent
            field: Field being processed
            
        Returns:
            Tuple of (value, source) if available, None otherwise
        """
        # Handle string results (may be JSON or markdown)
        if isinstance(result, str):
            # Try to extract JSON if in markdown format
            import re
            if "```json" in result:
                pattern = r"```json\s*([\s\S]+?)\s*```"
                match = re.search(pattern, result)
                if match:
                    json_str = match.group(1).strip()
                    try:
                        result = json.loads(json_str)
                    except json.JSONDecodeError:
                        pass
            else:
                # Try to parse as JSON directly
                try:
                    result = json.loads(result)
                except json.JSONDecodeError:
                    pass
        
        # Handle dict results
        if isinstance(result, dict):
            # Standard format where field is a nested object with value and source
            if field in result and isinstance(result[field], dict):
                field_data = result[field]
                if "value" in field_data:
                    value = field_data["value"]
                    # Convert to boolean for boolean fields
                    if field in self.BOOLEAN_FIELDS:
                        if isinstance(value, bool):
                            boolean_value = value
                        else:
                            # Handle string representations like "true", "yes", "1", etc.
                            boolean_value = str(value).lower() in ["true", "yes", "1", "t", "y"]
                        return boolean_value, field_data.get("source", "")
                    return value, field_data.get("source", "")
            
            # Direct value format for similar brands
            elif "value" in result and field == "similarBrandsEu":
                return result["value"], result.get("source", "")
        
        return None
    
    async def process_brand(self, brand: BrandLiteracy, session) -> Dict[str, bool]:
        """
        Process all fields for a brand in sequence.
        
        Args:
            brand: BrandLiteracy object to process
            session: Database session
            
        Returns:
            Dictionary of field to success status
        """
        logger.info(f"Processing brand: {brand.name}")
        results = {}
        
        for field in self.field_order:
            # Skip fields that already have values
            if getattr(brand, field, None) not in [None, "", "Unknown"]:
                logger.info(f"Skipping {field} for {brand.name} as it already has a value")
                results[field] = True
                continue
            
            # Process the field
            success = await self.process_brand_field(brand, field, session)
            results[field] = success
            
            # If processing failed for mandatory fields, stop processing this brand
            if not success and field in ["parentCompany", "brandOrigin"]:
                logger.warning(f"Failed to process required field {field} for {brand.name}, stopping")
                break
                
        return results
