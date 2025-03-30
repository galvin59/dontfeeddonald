import os
import sys
import requests
from sqlalchemy.orm import sessionmaker
from sqlalchemy import create_engine, Column, Integer, String, Boolean, Float, DateTime, Text
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.sql import func
from dotenv import load_dotenv
from duckduckgo_search import DDGS
import logging
from urllib.parse import urlparse

# --- Configuration ---
# Load environment variables from .env file in the current directory
load_dotenv() # Looks for .env in the current directory by default

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

# Database connection - uses environment variables loaded from .env
DB_USER = os.getenv("DB_USERNAME") # Changed from DB_USER
DB_PASSWORD = os.getenv("DB_PASSWORD")
DB_HOST = os.getenv("DB_HOST")
DB_PORT = os.getenv("DB_PORT")
DB_NAME = os.getenv("DB_DATABASE") # Changed from DB_NAME
DB_SSL = os.getenv("DB_SSL", "false").lower() == "true" # Default to false if not set

if not all([DB_USER, DB_PASSWORD, DB_HOST, DB_PORT, DB_NAME]):
    logging.error("Database environment variables (DB_USERNAME, DB_PASSWORD, DB_HOST, DB_PORT, DB_DATABASE) not set in .env file.")
    sys.exit(1)

DATABASE_URL = f"postgresql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}"

connect_args = {}
if DB_SSL:
    connect_args['sslmode'] = 'require'
    logging.info("Connecting to DB with SSL enabled.")

engine = create_engine(DATABASE_URL, connect_args=connect_args)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

# --- Database Model ---
# Define the BrandLiteracy model (mirroring app/models.py for standalone use)
# Ideally, import this from app.models if the script structure allows
class BrandLiteracy(Base):
    __tablename__ = "brand_literacy"

    # Primary key
    id = Column(Integer, primary_key=True, index=True)

    # Mandatory fields from app/models.py
    name = Column(String(255), index=True, nullable=False)
    brandOrigin = Column(String(2), nullable=False, comment="2 letters international ISO format for country")
    parentCompany = Column(String(255), nullable=False)

    # Optional fields from app/models.py
    logoUrl = Column(Text, nullable=True) # Updated from String
    productFamily = Column(String(255), nullable=True) # Updated from String

    # Boolean fields with sources from app/models.py
    usEmployees = Column(Boolean, nullable=True)
    usEmployeesSource = Column(Text, nullable=True)
    euEmployees = Column(Boolean, nullable=True)
    euEmployeesSource = Column(Text, nullable=True)
    usFactory = Column(Boolean, nullable=True)
    usFactorySource = Column(Text, nullable=True)
    euFactory = Column(Boolean, nullable=True)
    euFactorySource = Column(Text, nullable=True)
    usSupplier = Column(Boolean, nullable=True)
    usSupplierSource = Column(Text, nullable=True)
    euSupplier = Column(Boolean, nullable=True)
    euSupplierSource = Column(Text, nullable=True)

    # Metadata fields
    createdAt = Column(DateTime(timezone=True), server_default=func.now())
    updatedAt = Column(DateTime(timezone=True), onupdate=func.now())
    isEnabled = Column(Boolean, default=True)
    isError = Column(Boolean, default=False)

# --- Helper Functions ---
def is_valid_image_url(url: str, timeout: int = 5) -> bool:
    """Checks if a URL points to a valid, accessible image."""
    try:
        # Check if it looks like an image URL first (basic check)
        parsed = urlparse(url)
        if not parsed.scheme or not parsed.netloc:
            return False
        # Common image extensions - add more if needed
        if not any(url.lower().endswith(ext) for ext in ['.png', '.jpg', '.jpeg', '.gif', '.webp', '.svg']):
             logging.debug(f"URL does not end with known image extension: {url}")
             # Allow checking even without extension, header check is key
             # return False 

        headers = {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
        }
        # Use HEAD request first to be lighter
        response = requests.head(url, timeout=timeout, headers=headers, allow_redirects=True)
        
        if response.status_code == 200:
            content_type = response.headers.get('content-type', '').lower()
            if content_type.startswith('image/'):
                logging.debug(f"Valid image found via HEAD: {url} (Content-Type: {content_type})")
                return True
            else:
                 logging.debug(f"HEAD OK, but Content-Type not image: {content_type} for {url}")
                 # Optional: Fallback to GET if HEAD content-type is ambiguous/missing?
                 # response_get = requests.get(url, stream=True, timeout=timeout, headers=headers)
                 # if response_get.status_code == 200 and response_get.headers.get('content-type', '').lower().startswith('image/'):
                 #      logging.debug(f"Valid image confirmed via GET: {url}")
                 #      response_get.close() # Close the stream
                 #      return True
                 # response_get.close()
                 return False # Sticking to HEAD check mainly
        else:
             logging.debug(f"HEAD request failed for {url} with status: {response.status_code}")
             return False

    except requests.exceptions.Timeout:
        logging.warning(f"Timeout checking URL: {url}")
        return False
    except requests.exceptions.RequestException as e:
        logging.warning(f"Error checking URL {url}: {e}")
        return False
    except Exception as e:
        logging.error(f"Unexpected error checking URL {url}: {e}")
        return False


def search_logo(brand_name: str, product_family: str | None, max_results: int = 10):
    """Searches DuckDuckGo for logo images and yields potential URLs."""
    query_parts = ["logo png", brand_name]
    if product_family and product_family.strip():
        query_parts.append(product_family.strip())
    query = " ".join(query_parts)
    logging.info(f"Searching DuckDuckGo Images for: \"{query}\"")
    try:
        with DDGS() as ddgs:
            # Fetch image search results
            results = ddgs.images(
                query,
                region="wt-wt",
                safesearch="off",
                size=None,
                type_image=None, # Change to "photo", "clipart", "gif", "transparent", "line" if needed
                layout=None,
                license_image=None,
                max_results=max_results
            )
            count = 0
            for r in results:
                 if count >= max_results:
                     break
                 if isinstance(r, dict) and 'image' in r:
                     yield r['image']
                     count += 1
                 else:
                      logging.warning(f"Unexpected result format: {r}")


    except Exception as e:
        logging.error(f"Error during DuckDuckGo search for '{brand_name}': {e}")
        # Consider adding a retry mechanism or delay here if needed


# --- Main Logic ---
def find_and_process_brands(): # Renamed function
    db = SessionLocal()
    processed_count = 0
    updated_count = 0
    total_brands_to_process = 0 # To store total count
    try:
        # Find the first brand with logoUrl == NULL, order by ID for consistency
        logging.info(f"Searching for ALL brands with a NULL logoUrl, ordered by name...")
        brands_to_process = db.query(BrandLiteracy).filter(BrandLiteracy.logoUrl == None).order_by(BrandLiteracy.name).all()
        total_brands_to_process = len(brands_to_process)

        if not brands_to_process:
            logging.info("No brands found with a NULL logoUrl matching the criteria.")
            return
        logging.info(f"Found {total_brands_to_process} brands to process.")

        for brand in brands_to_process:
            processed_count += 1
            logging.info(f"--- Processing brand {processed_count}/{total_brands_to_process}: ID={brand.id}, Name={brand.name}, Family={brand.productFamily} ---")
            found_logo_url = None
            checked_urls = 0

            for image_url in search_logo(brand.name, brand.productFamily, max_results=15): # Check top 15 results
                logging.debug(f"Checking image URL: {image_url}")
                checked_urls += 1
                if is_valid_image_url(image_url):
                    found_logo_url = image_url
                    logging.info(f"SUCCESS: Found valid logo for \"{brand.name}\": {found_logo_url}")
                    break # Stop after finding the first valid one
                # Optional: Add a small delay between checks if needed
                # import time
                # time.sleep(0.5)

            if found_logo_url:
                # --- Update the database ---
                update_db = True # Set to True to enable DB update (Now enabled by default)
                if update_db:
                    try:
                        brand.logoUrl = found_logo_url
                        brand.updatedAt = func.now() # Explicitly update timestamp
                        db.commit()
                        logging.info(f"DB UPDATE: Successfully updated logoUrl for brand ID {brand.id}.")
                        updated_count += 1
                    except Exception as e:
                        db.rollback()
                        logging.error(f"DB ERROR: Failed to update database for brand ID {brand.id}: {e}")
                # else:
                #    logging.warning("Database update is disabled. Found logo URL was not saved.")
                # --- End Update ---
            else:
                logging.warning(f"NOT FOUND: Could not find a valid logo for \"{brand.name}\" after checking {checked_urls} image URLs.")
            logging.info(f"--- Finished processing brand {brand.name} --- ")

    except Exception as e:
        logging.error(f"An error occurred during processing: {e}")
        # Ensure rollback if any transaction was pending
        if 'db' in locals() and db.is_active:
             db.rollback()
    finally:
        if 'db' in locals():
            db.close()
            logging.debug("Database session closed.")
    logging.info(f"==================== Summary ====================")
    logging.info(f"Attempted processing for {total_brands_to_process} brands initially found with NULL logoUrl.")
    logging.info(f"Successfully found and updated logos for {updated_count} brands.")
    logging.info(f"===============================================")

if __name__ == "__main__":
    find_and_process_brands()
