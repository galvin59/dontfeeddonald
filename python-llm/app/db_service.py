"""
Database service for brand literacy operations.

This module provides functions to interact with the database for brand operations.
"""

import os
from datetime import datetime
from sqlalchemy import create_engine, select, update
from sqlalchemy.orm import sessionmaker
from sqlalchemy.ext.declarative import declarative_base
from typing import List, Optional, Dict, Any, Tuple

from app.models import BrandLiteracy, Base

# Database connection
def get_db_connection_string():
    """Get the database connection string from environment variables."""
    # Always use 'postgresql' as the dialect name for SQLAlchemy (not 'postgres')
    # Regardless of what's in DB_TYPE env var, SQLAlchemy requires 'postgresql'
    db_host = os.environ.get("DB_HOST", "localhost")
    db_port = os.environ.get("DB_PORT", "5432")
    db_username = os.environ.get("DB_USERNAME", "Julien")
    db_password = os.environ.get("DB_PASSWORD", "")
    db_database = os.environ.get("DB_DATABASE", "duckDatabase")
    
    return f"postgresql://{db_username}:{db_password}@{db_host}:{db_port}/{db_database}"

def get_db_session():
    """Create and return a database session."""
    connection_string = get_db_connection_string()
    engine = create_engine(connection_string)
    
    # Create tables if they don't exist
    Base.metadata.create_all(engine)
    
    # Create session
    Session = sessionmaker(bind=engine)
    return Session()

def get_incomplete_brands(session, limit: int = 10, field: Optional[str] = None) -> List[BrandLiteracy]:
    """
    Get brands with missing information.
    
    Args:
        session: SQLAlchemy session
        limit: Maximum number of brands to return
        field: Optional specific field to check for incompleteness
    
    Returns:
        List of BrandLiteracy objects with incomplete information
    """
    query = select(BrandLiteracy)
    
    # Filter based on the required field
    if field == "parentCompany":
        query = query.where(
            (BrandLiteracy.parentCompany == None) | 
            (BrandLiteracy.parentCompany == "") | 
            (BrandLiteracy.parentCompany == "Unknown")
        )
    elif field == "brandOrigin":
        query = query.where(
            (BrandLiteracy.brandOrigin == None) | 
            (BrandLiteracy.brandOrigin == "") | 
            (BrandLiteracy.brandOrigin == "Unknown")
        )
    elif field == "logoUrl":
        query = query.where(
            (BrandLiteracy.logoUrl == None) | 
            (BrandLiteracy.logoUrl == "")
        )
    elif field == "similarBrandsEu":
        query = query.where(
            (BrandLiteracy.similarBrandsEu == None) | 
            (BrandLiteracy.similarBrandsEu == "")
        )
    elif field == "totalEmployees":
        query = query.where(
            (BrandLiteracy.totalEmployees == None) | 
            (BrandLiteracy.totalEmployees == "")
        )
    elif field == "employeesUS":
        query = query.where(
            (BrandLiteracy.employeesUS == None) | 
            (BrandLiteracy.employeesUS == "")
        )
    elif field == "economicImpact":
        query = query.where(
            (BrandLiteracy.economicImpact == None) | 
            (BrandLiteracy.economicImpact == "")
        )
    elif field == "factoryInFrance":
        query = query.where(
            (BrandLiteracy.factoryInFrance == None)
        )
    elif field == "factoryInEU":
        query = query.where(
            (BrandLiteracy.factoryInEU == None)
        )
    elif field == "frenchFarmer":
        query = query.where(
            (BrandLiteracy.frenchFarmer == None)
        )
    elif field == "euFarmer":
        query = query.where(
            (BrandLiteracy.euFarmer == None)
        )
    # No specific field, get any brand with any missing field
    else:
        # Separate text and boolean field conditions for clarity
        text_fields_condition = (
            (BrandLiteracy.parentCompany == None) | 
            (BrandLiteracy.parentCompany == "") | 
            (BrandLiteracy.parentCompany == "Unknown") |
            (BrandLiteracy.brandOrigin == None) | 
            (BrandLiteracy.brandOrigin == "") | 
            (BrandLiteracy.brandOrigin == "Unknown") |
            (BrandLiteracy.logoUrl == None) | 
            (BrandLiteracy.logoUrl == "") |
            (BrandLiteracy.similarBrandsEu == None) | 
            (BrandLiteracy.similarBrandsEu == "") |
            (BrandLiteracy.totalEmployees == None) | 
            (BrandLiteracy.totalEmployees == "") |
            (BrandLiteracy.employeesUS == None) | 
            (BrandLiteracy.employeesUS == "") |
            (BrandLiteracy.economicImpact == None) | 
            (BrandLiteracy.economicImpact == "")
        )
        
        # Boolean fields only need to check for NULL (not empty string)
        boolean_fields_condition = (
            (BrandLiteracy.factoryInFrance == None) |
            (BrandLiteracy.factoryInEU == None) |
            (BrandLiteracy.frenchFarmer == None) |
            (BrandLiteracy.euFarmer == None)
        )
        
        # Combine all conditions
        query = query.where(text_fields_condition | boolean_fields_condition)
    
    # Limit the results
    query = query.limit(limit)
    
    return list(session.execute(query).scalars().all())

def update_brand(session, brand_id: int, field: str, value: Any, source: str) -> bool:
    """
    Update a brand field with new information.
    
    Args:
        session: SQLAlchemy session
        brand_id: ID of the brand to update
        field: Field to update
        value: Value to set
        source: Source of the information
    
    Returns:
        True if successful, False otherwise
    """
    try:
        # Prepare update data with just the field and timestamp
        update_data = {field: value, "updatedAt": datetime.now()}
        
        # Check if source field exists in the model
        source_field = f"{field}Source"
        if hasattr(BrandLiteracy, source_field):
            update_data[source_field] = source
        
        # Update the brand
        stmt = update(BrandLiteracy).where(BrandLiteracy.id == brand_id).values(**update_data)
        session.execute(stmt)
        session.commit()
        return True
    except Exception as e:
        print(f"Error updating brand {brand_id}: {str(e)}")
        session.rollback()
        return False
