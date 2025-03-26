"""Services for the Brand Lookup Tool."""
import datetime
import re
from typing import Dict, Optional, Any, Tuple, List

from sqlalchemy.orm import Session
import openai

from app.models import BrandLiteracy
from app.database import get_db_session
from app.prompts import PROMPT_TEMPLATES


class BrandLookupService:
    """Service for looking up brand information using LLMs."""
    
    def __init__(self, api_key: Optional[str] = None):
        """Initialize the brand lookup service.
        
        Args:
            api_key: Optional OpenAI API key. If not provided, it will use the
                    key from environment variables.
        """
        if api_key:
            openai.api_key = api_key
    
    def lookup_brand_info(self, brand_name: str) -> Dict[str, Any]:
        """Look up information about a brand using LLM.
        
        Args:
            brand_name: The name of the brand to look up.
            
        Returns:
            Dictionary with brand information.
        """
        # Placeholder for actual LLM implementation
        # In a real implementation, we would make API calls to OpenAI
        brand_info = {
            "brandOrigin": self._lookup_brand_origin(brand_name),
            "parentCompany": self._lookup_parent_company(brand_name),
            "logoUrl": None,  # Will be implemented later
            "similarBrandsEu": None,  # Will be implemented later
        }
        
        # Additional optional fields with value/source pairs
        value_source_fields = [
            "totalEmployees",
            "employeesUS",
            "economicImpact",
            "factoryInFrance",
            "factoryInEU",
            "frenchFarmer",
            "euFarmer"
        ]
        
        for field in value_source_fields:
            value, source = self._lookup_value_source_pair(brand_name, field)
            brand_info[field] = value
            brand_info[f"{field}Source"] = source
        
        return brand_info
    
    def _lookup_brand_origin(self, brand_name: str) -> str:
        """Look up the country of origin for a brand.
        
        Args:
            brand_name: The name of the brand.
            
        Returns:
            Two-letter ISO country code.
        """
        # Placeholder - would use LLM in actual implementation
        return "US"  # Default placeholder
    
    def _lookup_parent_company(self, brand_name: str) -> str:
        """Look up the parent company of a brand.
        
        Args:
            brand_name: The name of the brand.
            
        Returns:
            Name of the parent company.
        """
        # Placeholder - would use LLM in actual implementation
        return f"Parent of {brand_name}"  # Default placeholder
    
    def _lookup_value_source_pair(self, brand_name: str, field: str) -> Tuple[Optional[str], Optional[str]]:
        """Look up a value/source pair for a brand.
        
        Args:
            brand_name: The name of the brand.
            field: The field to look up.
            
        Returns:
            Tuple of (value, source).
        """
        # Placeholder - would use LLM in actual implementation
        return None, None

class BrandRepository:
    """Repository for interacting with the brand_literacy table."""
    
    def get_brand_by_name(self, name: str) -> Optional[BrandLiteracy]:
        """Get a brand by name.
        
        Args:
            name: The name of the brand.
            
        Returns:
            Brand object or None if not found.
        """
        db: Session = get_db_session()
        try:
            return db.query(BrandLiteracy).filter(BrandLiteracy.name == name).first()
        finally:
            db.close()
    
    def update_brand_info(self, brand_id: int, brand_info: Dict[str, Any]) -> BrandLiteracy:
        """Update brand information.
        
        Args:
            brand_id: The ID of the brand to update.
            brand_info: Dictionary with brand information.
            
        Returns:
            Updated brand object.
        """
        db: Session = get_db_session()
        try:
            brand = db.query(BrandLiteracy).filter(BrandLiteracy.id == brand_id).first()
            if not brand:
                raise ValueError(f"Brand with ID {brand_id} not found")
            
            # Update only the fields that are provided
            for key, value in brand_info.items():
                if hasattr(brand, key):
                    setattr(brand, key, value)
            
            # Update timestamp fields for attempted lookups
            now = datetime.datetime.now()
            # We no longer track *_last_attempt fields to keep the schema clean
            # Field updates happen without tracking last attempt timestamps
            
            brand.updatedAt = now
            db.commit()
            return brand
        finally:
            db.close()
    
    def create_brand(self, brand_info: Dict[str, Any]) -> BrandLiteracy:
        """Create a new brand.
        
        Args:
            brand_info: Dictionary with brand information.
            
        Returns:
            Newly created brand object.
        """
        db: Session = get_db_session()
        try:
            # Ensure required fields are provided
            required_fields = ["name", "brandOrigin", "parentCompany"]
            for field in required_fields:
                if field not in brand_info:
                    raise ValueError(f"Missing required field: {field}")
            
            # Create new brand object
            brand = BrandLiteracy(**brand_info)
            brand.isEnabled = True
            brand.isError = False
            
            db.add(brand)
            db.commit()
            db.refresh(brand)
            return brand
        finally:
            db.close()
