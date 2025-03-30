"""Agent for querying LLMs for brand information."""
import json
import re
import asyncio
from typing import Dict, Any, List, Optional, Union, Type

from langchain_community.chat_models import ChatOpenAI
from langchain.agents import AgentExecutor, initialize_agent, AgentType
from langchain.callbacks.manager import AsyncCallbackManagerForToolRun, CallbackManagerForToolRun
from langchain_community.tools import BaseTool
from langchain_community.tools.ddg_search.tool import DuckDuckGoSearchRun
from langchain_community.utilities.wikipedia import WikipediaAPIWrapper
from langchain_community.tools.wikipedia.tool import WikipediaQueryRun
from pydantic import BaseModel, Field, validator

from app.models import BrandLiteracy
from app.prompts import PROMPT_TEMPLATES


# Define Pydantic models for the various response formats
class ParentCompanyResponse(BaseModel):
    field_name: str
    brand: str
    parentCompany: Optional[Dict[str, str]] = None
    
    @validator("parentCompany")
    def validate_parent_company(cls, v):
        if v is not None:
            if "value" not in v or "source" not in v:
                raise ValueError("parentCompany must contain 'value' and 'source' fields")
        return v

class BrandOriginResponse(BaseModel):
    field_name: str
    brand: str
    brandOrigin: Optional[Dict[str, str]] = None
    
    @validator("brandOrigin")
    def validate_brand_origin(cls, v):
        if v is not None:
            if "value" not in v or "source" not in v:
                raise ValueError("brandOrigin must contain 'value' and 'source' fields")
            if len(v["value"]) != 2:
                raise ValueError("brandOrigin value must be a 2-letter ISO country code")
        return v

class ValueSourceResponse(BaseModel):
    field_name: str
    brand: str
    value: Optional[Dict[str, str]] = None
    
    @validator("value")
    def validate_value_source(cls, v):
        if v is not None:
            if "value" not in v or "source" not in v:
                raise ValueError("value must contain 'value' and 'source' fields")
        return v

class SimilarBrandsEuResponse(BaseModel):
    field_name: str
    brand: str
    value: Optional[List[str]] = None

# Map field names to their corresponding Pydantic models
FIELD_TO_MODEL = {
    "parentCompany": ParentCompanyResponse,
    "brandOrigin": BrandOriginResponse,
    "totalEmployees": ValueSourceResponse,
    "employeesUS": ValueSourceResponse,
    "economicImpact": ValueSourceResponse,
    "factoryInFrance": ValueSourceResponse,
    "factoryInEU": ValueSourceResponse,
    "frenchFarmer": ValueSourceResponse,
    "euFarmer": ValueSourceResponse,
    "similarBrandsEu": SimilarBrandsEuResponse,
}


# Define input schema for the BrandLookupTool
class BrandLookupToolInput(BaseModel):
    json_response: str = Field(..., description="The JSON response from the LLM to validate")
    field_name: str = Field(..., description="The field name to validate against (e.g., 'parentCompany')")

class BrandLookupTool(BaseTool):
    """Tool that validates a prompt response against a Pydantic model."""
    name: str = "validate_llm_response"
    description: str = "Validates that the LLM response conforms to the expected JSON format"
    args_schema: Type[BaseModel] = BrandLookupToolInput
    
    def _run(self, json_response: str, field_name: str) -> Dict[str, Any]:
        """Validate the LLM response using the appropriate Pydantic model."""
        try:
            # Try to clean up the response if it contains markdown code blocks
            if "```json" in json_response:
                # Extract content from JSON code block
                pattern = r"```json\s*([\s\S]+?)\s*```"
                match = re.search(pattern, json_response)
                if match:
                    json_response = match.group(1).strip()
            elif "```" in json_response:
                # Extract from generic code block
                pattern = r"```\s*([\s\S]+?)\s*```"
                match = re.search(pattern, json_response)
                if match:
                    json_response = match.group(1).strip()
            
            # Parse the JSON response
            response_dict = json.loads(json_response)
            
            # Get the appropriate Pydantic model for validation
            model = FIELD_TO_MODEL.get(field_name)
            if not model:
                return {"error": f"No validation model found for field: {field_name}"}
            
            # Validate using the Pydantic model
            validated_response = model.model_validate(response_dict)
            return validated_response.model_dump()
        except json.JSONDecodeError as e:
            # Return more helpful error message with the problematic JSON
            return {
                "error": f"Invalid JSON format in LLM response: {str(e)}",
                "json_response": json_response
            }
        except Exception as e:
            return {"error": f"Validation error: {str(e)}", "json_response": json_response}
    
    async def _arun(self, json_response: str, field_name: str) -> Dict[str, Any]:
        """Async version of _run."""
        return self._run(json_response, field_name)


class BrandLookupAgent:
    """Agent for looking up brand information using LLMs."""
    
    def __init__(self, model_name: str, temperature: float = 0.7):
        """Initialize the brand lookup agent.
        
        Args:
            model_name: The name of the model to use for the LLM.
            temperature: The temperature for the LLM.
        """
        # Set up LLM with connection to local Studio LM instance
        self.llm = ChatOpenAI(
            model=model_name,
            temperature=temperature,
            openai_api_base="http://localhost:1234/v1",  # Local Studio LM instance
            openai_api_key="dummy-key"  # The key doesn't matter for local instances
        )
        
        # Set up tools
        self.tools = [
            DuckDuckGoSearchRun(),
            WikipediaQueryRun(api_wrapper=WikipediaAPIWrapper()),
            BrandLookupTool(),
        ]
        
        # Initialize the agent using the standard initialize_agent method
        self.agent_executor = initialize_agent(
            tools=self.tools,
            llm=self.llm,
            agent=AgentType.OPENAI_FUNCTIONS,  # Using OPENAI_FUNCTIONS as it works well with function calling
            verbose=True,
            handle_parsing_errors=True,
        )
    def _format_prompt(self, brand_literacy: BrandLiteracy, field_name: str) -> str:
        """Format the prompt template by replacing placeholders with values from BrandLiteracy.
        
        Args:
            brand_literacy: The BrandLiteracy object.
            field_name: The field to look up.
            
        Returns:
            Formatted prompt string.
        """
        if field_name not in PROMPT_TEMPLATES:
            raise ValueError(f"No prompt template found for field: {field_name}")
        
        prompt = PROMPT_TEMPLATES[field_name]
        
        # Replace placeholders in the format {field_name} with values from brand_literacy
        placeholder_pattern = r"\{([a-zA-Z_]+)\}"
        
        def replace_placeholder(match):
            field = match.group(1)
            value = getattr(brand_literacy, field, None)
            if value is None:
                return f"{{{field}}}"  # Keep the original placeholder if field doesn't exist
            return str(value)
        
        formatted_prompt = re.sub(placeholder_pattern, replace_placeholder, prompt)
        return formatted_prompt
    
    async def lookup_field(self, brand_literacy: BrandLiteracy, field_name: str) -> Dict[str, Any]:
        """Look up information for a specific field of a brand.
        
        Args:
            brand_literacy: The BrandLiteracy object.
            field_name: The name of the field to look up.
            
        Returns:
            Dictionary with the lookup results.
        """
        # Format the prompt
        formatted_prompt = self._format_prompt(brand_literacy, field_name)
        
        # Execute the agent with the formatted prompt
        response = await self.agent_executor.ainvoke({
            "input": f"""
            I need to find information about the brand {brand_literacy.name}.
            Here is the specific task: {formatted_prompt}
            
            Please search for reliable information about this brand, then use the validate_llm_response 
            tool to ensure your final answer follows the required JSON format for field_name={field_name}.
            """
        })
        
        return response["output"]


# Example usage
async def example_usage():
    # Create a sample BrandLiteracy object
    brand = BrandLiteracy(
        name="Coca-Cola",
        brandOrigin="US",
        parentCompany="The Coca-Cola Company",
        productFamily="Boissons gazeuses"
    )
    
    # Initialize the agent
    agent = BrandLookupAgent(model_name="mistral")
    
    # Look up the parent company
    result = await agent.lookup_field(brand, "parentCompany")
    print(json.dumps(result, indent=2, ensure_ascii=False))


if __name__ == "__main__":
    import asyncio
    asyncio.run(example_usage())
