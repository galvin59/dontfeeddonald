"""
Database service for brand literacy operations.

This module provides functions to interact with the database for brand operations.
"""

import os
from datetime import datetime
from sqlalchemy import create_engine, select, update, or_
from sqlalchemy.orm import sessionmaker
from sqlalchemy.ext.declarative import declarative_base
from typing import List, Optional, Dict, Any, Tuple

from app.models import BrandLiteracy, Base

# Database connection
# Define fields to check for incompleteness
# Keep this consistent with the BrandLiteracy model
TEXT_FIELDS_TO_CHECK = [
    "parentCompany",
    "brandOrigin",
    "logoUrl",
    "productFamily" # Added as it's in the model now
]

BOOLEAN_FIELDS_TO_CHECK = [
    "usEmployees",
    "euEmployees",
    "usFactory",
    "euFactory",
    "usSupplier",
    "euSupplier"
]

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
    
    # If a specific field is provided, filter for that field being incomplete
    if field:
        field_attr = getattr(BrandLiteracy, field, None)
        if field_attr is None:
            raise ValueError(f"Invalid field name: {field}")
        
        if field in TEXT_FIELDS_TO_CHECK:
            # Handle special case for parentCompany and brandOrigin needing 'Unknown' check
            if field in ["parentCompany", "brandOrigin"]:
                query = query.where(
                    (field_attr == None) | (field_attr == "") | (field_attr == "Unknown")
                )
            else:
                query = query.where(
                    (field_attr == None) | (field_attr == "")
                )
        elif field in BOOLEAN_FIELDS_TO_CHECK:
            query = query.where(field_attr == None)
        # If field is not in TEXT or BOOLEAN checks, it's likely valid but not checked for incompleteness here
        # e.g., name, id, created_at, updated_at
        
    else:
        # No specific field provided, find brands missing ANY of the checkable fields
        conditions = []
        # Text fields (check for None, empty, and sometimes 'Unknown')
        for text_field in TEXT_FIELDS_TO_CHECK:
            field_attr = getattr(BrandLiteracy, text_field)
            if text_field in ["parentCompany", "brandOrigin"]:
                conditions.append((field_attr == None) | (field_attr == "") | (field_attr == "Unknown"))
            else:
                conditions.append((field_attr == None) | (field_attr == ""))
        
        # Boolean fields (check for None)
        for bool_field in BOOLEAN_FIELDS_TO_CHECK:
            field_attr = getattr(BrandLiteracy, bool_field)
            conditions.append(field_attr == None)
        
        # Combine all conditions with OR
        if conditions:
            query = query.where(or_(*conditions))
    
    # Order by update timestamp (oldest first)
    query = query.order_by(BrandLiteracy.updatedAt.asc()).limit(limit)
    
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
