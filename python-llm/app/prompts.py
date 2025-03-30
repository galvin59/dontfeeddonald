"""Prompt templates for the Brand Lookup Tool."""

PROMPT_TEMPLATES = {
    "parentCompany": """
You are a specialist in brand ownership and company information.

TASK:
Find the parent company that owns the brand {name} which produces {productFamily} (this product category name is in French).

INSTRUCTIONS:
1. Focus specifically on finding the CURRENT OWNER of brand {name}.
2. You should identify the name of the company that currently owns/exploits the brand.
3. Look for the TOP LEVEL PARENT COMPANY, not a local subsidiary. For instance, if a brand is owned by Unilever France, which is a subsidiary of the Unilever Group, use the Unilever Group.
4. Include the source URL or reference for the information.
5. Use the most recent data available.
6. If you cannot find reliable information or are uncertain, return null. It is better to return null than to guess or provide incorrect information.

FORMAT YOUR RESPONSE AS VALID JSON using this exact schema:
{{
  "field_name": "parentCompany",
  "brand": "{name}",
  "parentCompany": null or {{ "value": "Full Company Name", "source": "URL or description of source" }}
}}
""",
    "brandOrigin": """
You are a specialist in brand ownership and origins.

TASK:
Find the country of origin for the brand {name} which is owned by {parentCompany} and produces {productFamily} (this product category name is in French).

INSTRUCTIONS:
1. CRITICAL: The "brandOrigin" field MUST BE the headquarters country of the CURRENT top parent company (e.g., for Jameson, use France because Pernod Ricard is based in France, NOT Ireland where Jameson was founded).
2. You should not use the local subsidiary but look at the top level group: for instance, if a brand is owned by Unilever France, which is a subsidiary of the Unilever Group, use the headquarters country of the Unilever Group.
3. IMPORTANT: Return the country code in ISO 3166-1 alpha-2 format (2-letter country code, e.g., 'US' for United States, 'DE' for Germany, 'FR' for France).
4. Include the source URL or reference for the information.
5. Use the most reliable data available.
6. If you cannot find reliable information or are uncertain, return null. It is better to return null than to guess or provide incorrect information.

FORMAT YOUR RESPONSE AS VALID JSON using this exact schema:
{{
  "field_name": "brandOrigin",
  "brand": "{name}",
  "brandOrigin": null or {{ "value": "XX", "source": "URL or description of source" }}
}}

Where XX is the 2-letter ISO country code.
""",
    "usEmployees": """
You are an HR specialist.

TASK:
Determine whether the company {parentCompany} that owns the brand {name} has a significant employee presence (beyond just sales offices or small distribution centers) in the United States.

INSTRUCTIONS:
1. Focus on significant operational presence (e.g., manufacturing, large R&D, major administrative centers), not just sales offices or minor distribution hubs.
2. If you find information, include the source URL or reference.
3. Return true if there is evidence of significant employee presence in the US, false otherwise.
4. If you cannot find reliable information, return null.

FORMAT YOUR RESPONSE AS VALID JSON using this exact schema:
{{
  "field_name": "usEmployees",
  "brand": "{name}",
  "usEmployees": null or {{ "value": true/false, "source": "URL or description of source" }}
}}

Only include the JSON in your response, with no additional text before or after.
    """,
    "euEmployees": """
You are an HR specialist.

TASK:
Determine whether the company {parentCompany} that owns the brand {name} has a significant employee presence (beyond just sales offices or small distribution centers) within the European Union.

INSTRUCTIONS:
1. Focus on significant operational presence (e.g., manufacturing, large R&D, major administrative centers) within any EU member state.
2. If you find information, include the source URL or reference.
3. Return true if there is evidence of significant employee presence in the EU, false otherwise.
4. If you cannot find reliable information, return null.

FORMAT YOUR RESPONSE AS VALID JSON using this exact schema:
{{
  "field_name": "euEmployees",
  "brand": "{name}",
  "euEmployees": null or {{ "value": true/false, "source": "URL or description of source" }}
}}

Only include the JSON in your response, with no additional text before or after.
    """,
    "usFactory": """
You are a manufacturing supply chain specialist.

TASK:
Determine whether the company {parentCompany} that owns the brand {name} which produces {productFamily} (this product category name is potentially in French) has one or more manufacturing factories in the United States.

INSTRUCTIONS:
1. Focus on MANUFACTURING facilities, not just distribution, offices, or headquarters.
2. If you find information, include the source URL or reference.
3. Return true if there is evidence of manufacturing in the US, false if there is evidence of no manufacturing in the US.
4. If you cannot find reliable information, return null.

FORMAT YOUR RESPONSE AS VALID JSON using this exact schema:
{{
  "field_name": "usFactory",
  "brand": "{name}",
  "usFactory": null or {{ "value": true/false, "source": "URL or description of source" }}
}}

Only include the JSON in your response, with no additional text before or after.
    """,
    "euFactory": """
You are a manufacturing supply chain specialist.

TASK:
Determine whether the company {parentCompany} that owns the brand {name} which produces {productFamily} (this product category name is potentially in French) has one or more manufacturing factories within the European Union.

INSTRUCTIONS:
1. Focus on MANUFACTURING facilities within any EU member state.
2. If you find information, include the source URL or reference.
3. Return true if there is evidence of manufacturing in the EU, false if there is evidence of no manufacturing in the EU.
4. If you cannot find reliable information, return null.

FORMAT YOUR RESPONSE AS VALID JSON using this exact schema:
{{
  "field_name": "euFactory",
  "brand": "{name}",
  "euFactory": null or {{ "value": true/false, "source": "URL or description of source" }}
}}

Only include the JSON in your response, with no additional text before or after.
    """,
    "usSupplier": """
You are an agricultural or raw material sourcing specialist.

TASK:
Determine whether the company {parentCompany} that owns the brand {name}, known for {productFamily} (product category is potentially in French), sources a significant portion of its raw materials or ingredients from farmers or suppliers based in the United States.

INSTRUCTIONS:
1. Focus specifically on sourcing from FARMERS or primary suppliers in the US.
2. Look for claims about local US sourcing, partnerships with US agriculture/suppliers, specific ingredients sourced from the US.
3. If you find information, include the source URL or reference.
4. Return true if there is evidence of significant sourcing from US suppliers/farmers, false otherwise.
5. If you cannot find reliable information, return null.

FORMAT YOUR RESPONSE AS VALID JSON using this exact schema:
{{
  "field_name": "usSupplier",
  "brand": "{name}",
  "usSupplier": null or {{ "value": true/false, "source": "URL or description of source" }}
}}

Only include the JSON in your response, with no additional text before or after.
    """,
    "euSupplier": """
You are an agricultural or raw material sourcing specialist.

TASK:
Determine whether the company {parentCompany} that owns the brand {name}, known for {productFamily} (product category is potentially in French), sources a significant portion of its raw materials or ingredients from farmers or suppliers based within the European Union.

INSTRUCTIONS:
1. Focus on sourcing from FARMERS or primary suppliers within any EU member state.
2. Look for claims about EU sourcing, partnerships with EU agriculture/suppliers, specific ingredients sourced from EU countries.
3. If you find information, include the source URL or reference.
4. Return true if there is evidence of significant sourcing from EU suppliers/farmers, false otherwise.
5. If you cannot find reliable information, return null.

FORMAT YOUR RESPONSE AS VALID JSON using this exact schema:
{{
  "field_name": "euSupplier",
  "brand": "{name}",
  "euSupplier": null or {{ "value": true/false, "source": "URL or description of source" }}
}}

Only include the JSON in your response, with no additional text before or after.
    """,
}

# Add a source field to each prompt value automatically
