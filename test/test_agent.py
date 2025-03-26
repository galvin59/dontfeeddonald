"""Test script for the BrandLookupAgent and logo search."""
import asyncio
import json
import os
import sys

# Ensure langchain_openai uses local API path
os.environ["OPENAI_API_BASE"] = "http://localhost:1234/v1"

from app.agent import BrandLookupAgent
from app.models import BrandLiteracy
from app.logo_search import search_brand_logo

async def test_brand_lookup_agent():
    """Test the BrandLookupAgent with a beer brand."""
    print("\n===== Brand Lookup Agent Test =====\n")
    
    # Create a sample BrandLiteracy object for 1664 beer
    print("Creating test brand: 1664 (Bières)")
    brand = BrandLiteracy(
        name="1664",
        brandOrigin="FR",  # Placeholder, will be looked up
        parentCompany="Unknown",  # Placeholder, will be looked up
        productFamily="Bières"
    )
    
    try:
        # Initialize the agent with the mistral model
        print("\nInitializing LLM agent with model: mistral")
        agent = BrandLookupAgent(model_name="mistral", temperature=0.1)
        
        # PART 1: Test parent company lookup
        print(f"\nLooking up parent company for brand: {brand.name}...")
        print("This may take a moment as the agent searches for information...\n")
        
        # Look up the parent company
        result = await agent.lookup_field(brand, "parentCompany")
        
        # Print the result in a formatted way
        print("\n----- LLM Response -----")
        # If the result is a string, try to parse it as JSON
        if isinstance(result, str):
            print(result)
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
            print(json.dumps(result, indent=2, ensure_ascii=False))
        print("-----------------------\n")
        
        # Extract the parent company value if available
        parent_company_found = False
        
        if isinstance(result, dict) and "parentCompany" in result:
            if result["parentCompany"] and isinstance(result["parentCompany"], dict) and "value" in result["parentCompany"]:
                print(f"✅ Found parent company: {result['parentCompany']['value']}")
                print(f"📚 Source: {result['parentCompany']['source']}")
                # Update the brand object with the found parent company
                brand.parentCompany = result["parentCompany"]["value"]
                parent_company_found = True
            else:
                print("❌ No parent company information found or it was null")
        else:
            # Try to check if result is a JSON string response that needs parsing
            if isinstance(result, str):
                try:
                    result_dict = json.loads(result)
                    if "parentCompany" in result_dict and isinstance(result_dict["parentCompany"], dict):
                        print(f"✅ Found parent company: {result_dict['parentCompany']['value']}")
                        print(f"📚 Source: {result_dict['parentCompany']['source']}")
                        # Update the brand object with the found parent company
                        brand.parentCompany = result_dict["parentCompany"]["value"]
                        parent_company_found = True
                except json.JSONDecodeError:
                    pass
            
            if not parent_company_found:
                print("❓ Unexpected response format from LLM")
            
        # PART 2: Test logo search if parent company was found
        if brand.parentCompany != "Unknown":
            print("\n===== Brand Logo Search Test =====\n")
            print(f"Searching for logo of {brand.name} (owned by {brand.parentCompany})...")
            print("This may take a moment as we search for the logo...\n")
            
            # Search for the logo
            logo_result = search_brand_logo(brand)
            
            # Print the result
            print("\n----- Logo Search Response -----")
            print(json.dumps(logo_result, indent=2, ensure_ascii=False))
            print("-----------------------\n")
            
            # Check for logo URL
            if logo_result and "logo_url" in logo_result and logo_result["logo_url"]:
                logo_data = logo_result["logo_url"]
                if logo_data.get("value"):
                    print(f"✅ Found logo URL: {logo_data['value']}")
                    print(f"📚 Source: {logo_data['source']}")
                    
                    # Update the brand object with the logo URL
                    brand.logoUrl = logo_data["value"]
                else:
                    print("❌ No logo URL found")
            else:
                print("❌ No logo information returned")
                
            # PART 3: Test brand origin lookup
            print("\n===== Brand Origin Lookup Test =====\n")
            print(f"Looking up origin for brand: {brand.name}...")
            print("This may take a moment as the agent searches for information...\n")
            
            # Look up the brand origin
            origin_result = await agent.lookup_field(brand, "brandOrigin")
            
            # Print the result
            print("\n----- LLM Response for Brand Origin -----")
            if isinstance(origin_result, str):
                print(origin_result)
                # Try to extract JSON if in markdown format
                import re
                if "```json" in origin_result:
                    pattern = r"```json\s*([\s\S]+?)\s*```"
                    match = re.search(pattern, origin_result)
                    if match:
                        json_str = match.group(1).strip()
                        try:
                            origin_result = json.loads(json_str)
                        except json.JSONDecodeError:
                            pass
            else:
                print(json.dumps(origin_result, indent=2, ensure_ascii=False))
            print("-----------------------\n")
            
            # Extract the brand origin value if available
            origin_found = False
            
            if isinstance(origin_result, dict) and "brandOrigin" in origin_result:
                if origin_result["brandOrigin"] and isinstance(origin_result["brandOrigin"], dict) and "value" in origin_result["brandOrigin"]:
                    print(f"✅ Found brand origin: {origin_result['brandOrigin']['value']}")
                    print(f"📚 Source: {origin_result['brandOrigin']['source']}")
                    # Update the brand object with the found origin
                    brand.brandOrigin = origin_result["brandOrigin"]["value"]
                    origin_found = True
                else:
                    print("❌ No brand origin information found or it was null")
            else:
                # Try to check if result is a JSON string response that needs parsing
                if isinstance(origin_result, str):
                    try:
                        origin_dict = json.loads(origin_result)
                        if "brandOrigin" in origin_dict and isinstance(origin_dict["brandOrigin"], dict):
                            print(f"✅ Found brand origin: {origin_dict['brandOrigin']['value']}")
                            print(f"📚 Source: {origin_dict['brandOrigin']['source']}")
                            # Update the brand object with the found origin
                            brand.brandOrigin = origin_dict["brandOrigin"]["value"]
                            origin_found = True
                    except json.JSONDecodeError:
                        pass
                
                if not origin_found:
                    print("❓ Unexpected response format from LLM for brand origin")
                    
            # PART 4: Test similar brands lookup
            print("\n===== Similar Brands Lookup Test =====\n")
            print(f"Looking up similar brands for: {brand.name}...")
            print("This may take a moment as the agent searches for information...\n")
            
            # Look up similar brands
            similar_brands_result = await agent.lookup_field(brand, "similarBrandsEu")
            
            # Print the result
            print("\n----- LLM Response for Similar Brands -----")
            if isinstance(similar_brands_result, str):
                print(similar_brands_result)
                # Try to extract JSON if in markdown format
                import re
                if "```json" in similar_brands_result:
                    pattern = r"```json\s*([\s\S]+?)\s*```"
                    match = re.search(pattern, similar_brands_result)
                    if match:
                        json_str = match.group(1).strip()
                        try:
                            similar_brands_result = json.loads(json_str)
                        except json.JSONDecodeError:
                            pass
            else:
                print(json.dumps(similar_brands_result, indent=2, ensure_ascii=False))
            print("-----------------------\n")
            
            # Extract the similar brands value if available
            similar_brands_found = False
            
            # Handle case where similarBrandsEu is a nested object with value
            if isinstance(similar_brands_result, dict) and "similarBrandsEu" in similar_brands_result:
                if similar_brands_result["similarBrandsEu"] and isinstance(similar_brands_result["similarBrandsEu"], dict) and "value" in similar_brands_result["similarBrandsEu"]:
                    print(f"✅ Found similar brands: {similar_brands_result['similarBrandsEu']['value']}")
                    source = similar_brands_result['similarBrandsEu'].get('source', 'Not specified')
                    print(f"📚 Source: {source}")
                    # Update the brand object with the found similar brands
                    brand.similarBrandsEu = similar_brands_result["similarBrandsEu"]["value"]
                    similar_brands_found = True
            
            # Handle case where value is directly in the root object (as seen in the response)
            elif isinstance(similar_brands_result, dict) and "value" in similar_brands_result:
                if similar_brands_result["value"] and isinstance(similar_brands_result["value"], list):
                    print(f"✅ Found similar brands: {similar_brands_result['value']}")
                    source = similar_brands_result.get('source', 'Not specified')
                    print(f"📚 Source: {source}")
                    # Update the brand object with the found similar brands
                    brand.similarBrandsEu = similar_brands_result["value"]
                    similar_brands_found = True
            
            # Handle string responses
            elif isinstance(similar_brands_result, str):
                try:
                    # Try to parse as JSON
                    similar_brands_dict = json.loads(similar_brands_result)
                    
                    # Try nested format
                    if "similarBrandsEu" in similar_brands_dict and isinstance(similar_brands_dict["similarBrandsEu"], dict):
                        print(f"✅ Found similar brands: {similar_brands_dict['similarBrandsEu']['value']}")
                        source = similar_brands_dict['similarBrandsEu'].get('source', 'Not specified')
                        print(f"📚 Source: {source}")
                        # Update the brand object with the found similar brands
                        brand.similarBrandsEu = similar_brands_dict["similarBrandsEu"]["value"]
                        similar_brands_found = True
                    
                    # Try direct value format
                    elif "value" in similar_brands_dict and isinstance(similar_brands_dict["value"], list):
                        print(f"✅ Found similar brands: {similar_brands_dict['value']}")
                        source = similar_brands_dict.get('source', 'Not specified')
                        print(f"📚 Source: {source}")
                        # Update the brand object with the found similar brands
                        brand.similarBrandsEu = similar_brands_dict["value"]
                        similar_brands_found = True
                        
                except json.JSONDecodeError:
                    pass
            
            # If no format matched, report error
            if not similar_brands_found:
                print("❓ Unexpected response format from LLM for similar brands")
                print("The response format does not match any of the expected patterns.")
                
            # PART 5: Test factoryInEU lookup
            print("\n===== Factory In EU Lookup Test =====\n")
            print(f"Looking up factory presence in EU for brand: {brand.name}...")
            print("This may take a moment as the agent searches for information...\n")
            
            # Look up factory presence in EU
            factory_eu_result = await agent.lookup_field(brand, "factoryInEU")
            
            # Print the result
            print("\n----- LLM Response for Factory In EU -----")
            if isinstance(factory_eu_result, str):
                print(factory_eu_result)
                # Try to extract JSON if in markdown format
                import re
                if "```json" in factory_eu_result:
                    pattern = r"```json\s*([\s\S]+?)\s*```"
                    match = re.search(pattern, factory_eu_result)
                    if match:
                        json_str = match.group(1).strip()
                        try:
                            factory_eu_result = json.loads(json_str)
                        except json.JSONDecodeError:
                            pass
            else:
                print(json.dumps(factory_eu_result, indent=2, ensure_ascii=False))
            print("-----------------------\n")
            
            # Extract the factory in EU value if available
            factory_eu_found = False
            
            if isinstance(factory_eu_result, dict) and "factoryInEU" in factory_eu_result:
                if "value" in factory_eu_result["factoryInEU"]:
                    value = factory_eu_result["factoryInEU"]["value"]
                    # Ensure the value is interpreted as boolean
                    if isinstance(value, bool):
                        boolean_value = value
                    else:
                        # Handle string representations like "true", "yes", "1", etc.
                        boolean_value = str(value).lower() in ["true", "yes", "1", "t", "y"]
                    
                    print(f"✅ Factory in EU: {'Yes' if boolean_value else 'No'}")
                    source = factory_eu_result['factoryInEU'].get('source', 'Not specified')
                    print(f"📚 Source: {source}")
                    # Update the brand object with the found factory in EU status
                    brand.factoryInEU = boolean_value
                    factory_eu_found = True
            
            # Try to check if result is a JSON string response that needs parsing
            if not factory_eu_found and isinstance(factory_eu_result, str):
                try:
                    factory_eu_dict = json.loads(factory_eu_result)
                    if "factoryInEU" in factory_eu_dict and isinstance(factory_eu_dict["factoryInEU"], dict):
                        if "value" in factory_eu_dict["factoryInEU"]:
                            value = factory_eu_dict["factoryInEU"]["value"]
                            # Ensure the value is interpreted as boolean
                            if isinstance(value, bool):
                                boolean_value = value
                            else:
                                # Handle string representations
                                boolean_value = str(value).lower() in ["true", "yes", "1", "t", "y"]
                            
                            print(f"✅ Factory in EU: {'Yes' if boolean_value else 'No'}")
                            source = factory_eu_dict['factoryInEU'].get('source', 'Not specified')
                            print(f"📚 Source: {source}")
                            # Update the brand object
                            brand.factoryInEU = boolean_value
                            factory_eu_found = True
                except json.JSONDecodeError:
                    pass
            
            # If no format matched, report error
            if not factory_eu_found:
                print("❓ Unexpected response format from LLM for factory in EU")
                print("The response format does not match any of the expected patterns.")
    except KeyboardInterrupt:
        print("\n⚠️ Test interrupted by user")
    except ConnectionError as e:
        print(f"\n❌ Connection error: {str(e)}")
        print("Make sure the local LLM server is running at http://localhost:1234/v1")
    except Exception as e:
        print(f"\n❌ Error: {str(e)}")
        # Print more detailed error information for debugging
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    # Run the test
    asyncio.run(test_brand_lookup_agent())
