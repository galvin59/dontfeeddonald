"""Main application module for the Brand Lookup Tool."""
import argparse
from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy.orm import Session

from app.database import test_connection, get_db_session
from app.models import BrandLiteracy
from app.services import BrandLookupService, BrandRepository


def verify_table_exists():
    """Verify the brand_literacy table exists without modifying it.
    
    This function checks if the table exists and is accessible,
    but won't create or modify the table structure.
    """
    try:
        # Create a session
        db: Session = get_db_session()
        # Try to query the table (just count, don't fetch data)
        count = db.query(BrandLiteracy).count()
        print(f"Found {count} records in the brand_literacy table.")
        return True
    except SQLAlchemyError as e:
        print(f"Error accessing brand_literacy table: {e}")
        return False
    finally:
        if "db" in locals():
            db.close()


def lookup_brand(brand_name: str):
    """Look up information about a brand.
    
    Args:
        brand_name: The name of the brand to look up.
    """
    # Check if brand exists in database
    brand_repo = BrandRepository()
    brand = brand_repo.get_brand_by_name(brand_name)
    
    if brand:
        print(f"\nFound existing brand: {brand.name}")
        print(f"Parent company: {brand.parentCompany}")
        print(f"Country of origin: {brand.brandOrigin}")
    else:
        print(f"\nBrand not found in database: {brand_name}")
        print("Looking up information using LLM...")
        
        # Use the lookup service to get brand information
        lookup_service = BrandLookupService()
        brand_info = lookup_service.lookup_brand_info(brand_name)
        
        # Add required field
        brand_info["name"] = brand_name
        
        try:
            # Create new brand record
            new_brand = brand_repo.create_brand(brand_info)
            print(f"Created new brand record with ID: {new_brand.id}")
            print(f"Parent company: {new_brand.parentCompany}")
            print(f"Country of origin: {new_brand.brandOrigin}")
        except Exception as e:
            print(f"Error creating brand record: {e}")


def main():
    """Main function to run the application."""
    parser = argparse.ArgumentParser(description="Brand Lookup Tool")
    parser.add_argument("--brand", type=str, help="Brand name to look up")
    args = parser.parse_args()
    
    print("Brand Lookup Tool")
    print("=================")
    
    # Test database connection
    print("Testing database connection...")
    if test_connection():
        print("Successfully connected to the database.")
        
        # Verify the brand_literacy table exists
        print("Verifying access to the brand_literacy table...")
        if verify_table_exists():
            print("Successfully verified access to the brand_literacy table.")
            
            # If brand name is provided, look it up
            if args.brand:
                lookup_brand(args.brand)
            else:
                print("\nUse --brand argument to look up information about a specific brand.")
                print("Example: python -m app.main --brand 'Coca-Cola'")
        else:
            print("Failed to access the brand_literacy table. Make sure it exists in the database.")
            return
    else:
        print("Failed to connect to the database. Please check your configuration.")
        return


if __name__ == "__main__":
    main()
