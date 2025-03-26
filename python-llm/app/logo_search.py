"""
Direct logo search functionality.

This module provides direct logo search functions using various search APIs
to find brand logos without requiring an LLM.
"""

import os
import re
import requests
from typing import Dict, Any, Optional, List
from bs4 import BeautifulSoup  # Added for parsing HTML responses
from langchain_community.utilities import DuckDuckGoSearchAPIWrapper

# Import BrandLiteracy model
from app.models import BrandLiteracy

# Try to import from config, fallback to environment variables if not available
try:
    from config import GOOGLE_API_KEY, GOOGLE_CSE_ID
except ImportError:
    import os
    GOOGLE_API_KEY = os.environ.get("GOOGLE_API_KEY", "")
    GOOGLE_CSE_ID = os.environ.get("GOOGLE_CSE_ID", "")

def search_brand_logo_duckduckgo(brand_literacy: BrandLiteracy) -> Dict[str, Any]:
    """
    Search for a brand logo using DuckDuckGo
    
    Args:
        brand_literacy: The BrandLiteracy object containing information about the brand
        
    Returns:
        Dictionary containing the logo URL information
    """
    # Extract relevant fields from the BrandLiteracy object
    brand_name = brand_literacy.name
    parent_company = brand_literacy.parentCompany
    product_family = brand_literacy.productFamily
    print(f"Searching for logo of {brand_name} using DuckDuckGo Search")
    
    # Form the search query
    query = f"official logo of {brand_name} {product_family if product_family else ''} png"  # New query format as requested
    
    # Use DuckDuckGo search
    search = DuckDuckGoSearchAPIWrapper()
    try:
        # Get search results
        results = search.results(query, max_results=10)
        
        # Check each result
        for result in results:
            link = result.get('link', '')
            title = result.get('title', '')
            snippet = result.get('snippet', '')
            
            # Try to extract image URLs from HTML content if available
            try:
                # Get the actual page content
                response = requests.get(link, timeout=5)
                if response.status_code == 200:
                    soup = BeautifulSoup(response.text, 'html.parser')
                    
                    # Look for image tags
                    img_tags = soup.find_all('img')
                    for img in img_tags:
                        img_src = img.get('src', '')
                        img_alt = img.get('alt', '').lower()
                        
                        # Prepare for brand name matching
                        brand_name_lower = brand_name.lower()
                        # Remove spaces and special characters for matching in filenames
                        brand_name_simple = re.sub(r'[^a-z0-9]', '', brand_name_lower)
                        
                        # Get at least 3 letters of brand name for matching
                        if len(brand_name_simple) >= 3:
                            brand_substr = brand_name_simple[:3]  # Use at least first 3 letters
                        else:
                            brand_substr = brand_name_simple  # Use whole name if less than 3 letters
                        
                        # Extract filename from URL for checking
                        img_filename = os.path.basename(img_src.split('?')[0].lower())
                        
                        # STRICT VALIDATION: Check both brand name and logo requirements
                        brand_name_present = (
                            brand_name_lower in img_alt.lower() or
                            brand_name_simple in img_filename or
                            brand_substr in img_filename
                        )
                        
                        logo_indicator_present = (
                            'logo' in img_alt.lower() or
                            'logo' in img_filename
                        )
                        
                        valid_extension = (
                            img_src.endswith('.png') or 
                            img_src.endswith('.jpg') or 
                            img_src.endswith('.jpeg')
                        )
                        
                        # Must have both brand name and logo indicators, and valid extension
                        if brand_name_present and logo_indicator_present and valid_extension:
                            
                            # Make absolute URL if relative
                            if not img_src.startswith('http'):
                                base_url = '/'.join(link.split('/')[:3])
                                img_src = base_url + ('' if img_src.startswith('/') else '/') + img_src
                            
                            # Validate the image URL
                            try:
                                head_response = requests.head(img_src, timeout=3)
                                if head_response.status_code == 200:
                                    # Get file size if available
                                    file_size_bytes = 0
                                    if "content-length" in head_response.headers:
                                        file_size_bytes = int(head_response.headers["content-length"])
                                    file_size_kb = file_size_bytes / 1024
                                    
                                    # Only consider images of reasonable size
                                    if file_size_kb >= 5:  # Lower threshold than Google search
                                        logo_info = {
                                            "url": img_src,
                                            "source": link,
                                            "size_kb": file_size_kb
                                        }
                                        
                                        # This is our first valid match, return it immediately
                                        return {
                                            "field_name": "logo_url",
                                            "brand": brand_name,
                                            "file_size": f"{file_size_kb:.1f}ko",
                                            "logo_url": {
                                                "value": img_src,
                                                "source": link
                                            }
                                        }
                            except Exception as e:
                                print(f"Error validating image URL {img_src}: {str(e)}")
            except Exception as e:
                print(f"Error processing search result {link}: {str(e)}")
        
        # If we've gotten here, it means we didn't find a match in the loop
        
        # If no valid logos found, return empty object with attempted flag
        print(f"No valid logos found for {brand_name} with DuckDuckGo")
        return {
            "field_name": "logo_url",
            "brand": brand_name,
            "logo_url": {
                "value": "",  # Empty string instead of None
                "source": "", 
                "attempted": True
            }
        }
        
    except Exception as e:
        print(f"Error searching for logo with DuckDuckGo: {str(e)}")
        return {
            "field_name": "logo_url",
            "brand": brand_name,
            "logo_url": {
                "value": "",  # Empty string instead of None
                "source": "",
                "attempted": True
            },
            "error": str(e)
        }

def search_brand_logo(brand_literacy: BrandLiteracy) -> Dict[str, Any]:
    """
    Search for a brand logo using available search APIs.
    First tries DuckDuckGo, then falls back to Google Search API if needed.
    
    Args:
        brand_literacy: The BrandLiteracy object containing information about the brand
        
    Returns:
        Dictionary containing the logo URL information
    """
    # Extract relevant fields for the logging
    brand_name = brand_literacy.name
    product_family = brand_literacy.productFamily
    # First try with DuckDuckGo
    try:
        result = search_brand_logo_duckduckgo(brand_literacy)
        if result["logo_url"] is not None:
            return result
    except Exception as e:
        print(f"DuckDuckGo search failed: {str(e)}. Falling back to Google Search.")
    
    # Fall back to Google Search API
    print(f"Falling back to Google Image Search for {brand_name}")
    
    # Form the search query
    query = f"official logo of {brand_name} {product_family if product_family else ''} png"  # New query format as requested
    
    # Google Search API parameters
    base_url = "https://www.googleapis.com/customsearch/v1"
    params = {
        "q": query,
        "cx": GOOGLE_CSE_ID,
        "key": GOOGLE_API_KEY,
        "searchType": "image",
        "num": 10,  # Get up to 10 results
        "imgType": "clipart",  # Prefer clipart which often includes logos
        "safe": "active"
    }
    
    try:
        response = requests.get(base_url, params=params)
        
        if response.status_code != 200:
            print(f"Google Search API error: {response.status_code}\n{response.text}")
            return {
                "field_name": "logo_url",
                "brand": brand_name,
                "logo_url": {
                    "value": "",  # Empty string instead of None
                    "source": "",
                    "attempted": True
                }
            }
            
        results = response.json()
        
        if "items" not in results or not results["items"]:
            print(f"No image results found for {brand_name}")
            return {
                "field_name": "logo_url",
                "brand": brand_name,
                "logo_url": {
                    "value": "",  # Empty string instead of None
                    "source": "",
                    "attempted": True
                }
            }
        
        # Process results to find valid logos
        for item in results["items"]:
            # Skip if no link
            if "link" not in item:
                continue
                
            logo_url = item["link"]
            context_url = item.get("image", {}).get("contextLink", "")
            
            # Get file size if available
            file_size_bytes = item.get("image", {}).get("byteSize", 0)
            file_size_kb = int(file_size_bytes) / 1024
            
            # Prepare for brand name matching
            brand_name_lower = brand_name.lower()
            # Remove spaces and special characters for matching in filenames
            brand_name_simple = re.sub(r'[^a-z0-9]', '', brand_name_lower)
            
            # Get at least 3 letters of brand name for matching
            if len(brand_name_simple) >= 3:
                brand_substr = brand_name_simple[:3]  # Use at least first 3 letters
            else:
                brand_substr = brand_name_simple  # Use whole name if less than 3 letters
            
            # Extract filename from URL for checking
            img_filename = os.path.basename(logo_url.split('?')[0].lower())
            
            # STRICT VALIDATION: Check both brand name and logo requirements
            brand_name_present = (
                brand_name_lower in img_filename or
                brand_name_simple in img_filename or
                brand_substr in img_filename
            )
            
            logo_indicator_present = (
                'logo' in img_filename
            )
            
            valid_extension = (
                logo_url.endswith('.png') or 
                logo_url.endswith('.jpg') or 
                logo_url.endswith('.jpeg')
            )
            
            # Validate URL by making a HEAD request
            try:
                if brand_name_present and logo_indicator_present and valid_extension:
                    head_response = requests.head(logo_url, timeout=5)
                    is_valid_url = head_response.status_code == 200
                    
                    # Double-check content size if not in metadata
                    if file_size_bytes == 0 and "content-length" in head_response.headers:
                        file_size_bytes = int(head_response.headers["content-length"])
                        file_size_kb = file_size_bytes / 1024
                    
                    # Only consider valid URLs with size > 10KB
                    if is_valid_url and file_size_kb >= 10:
                        # Found a valid logo, return it immediately
                        return {
                            "field_name": "logo_url",
                            "brand": brand_name,
                            "file_size": f"{file_size_kb:.1f}ko",
                            "logo_url": {
                                "value": logo_url,
                                "source": context_url
                            }
                        }
            except Exception as e:
                print(f"Error validating URL {logo_url}: {str(e)}")
        
        # If we reach here, no valid logo was found
        print(f"No valid logo found for {brand_name} with Google Search API")
        return {
            "field_name": "logo_url",
            "brand": brand_name,
            "logo_url": {
                "value": "",  # Empty string instead of None
                "source": "",
                "attempted": True
            }
        }
            
    except Exception as e:
        print(f"Error searching for logo: {str(e)}")
        return {
            "field_name": "logo_url",
            "brand": brand_name,
            "logo_url": {
                "value": "",  # Empty string instead of None
                "source": "",
                "attempted": True
            },
            "error": str(e)
        }
