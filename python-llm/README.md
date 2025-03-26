# Brand Lookup Tool

A Python application that uses LLMs to lookup information about brands, such as parent companies, brand origin, logos, and more. This tool automatically completes missing information for brands stored in a PostgreSQL database using LangChain agents and search tools.

## Architecture

- **Database Layer**: Uses SQLAlchemy ORM with PostgreSQL
- **Agent Layer**: Uses LangChain agents with a local LLM
- **Processing Layer**: Sequential field processing with failover
- **CLI Layer**: Command-line tools for interacting with the system

## Setup

1. Install dependencies:
```bash
pip install -r requirements.txt
```

2. Configure your database:
   - Make sure PostgreSQL is installed and running
   - Database credentials are stored in the `.env` file
   - Update the `.env` file with your database credentials if needed

```
DB_TYPE=postgres
DB_HOST=localhost
DB_PORT=5432
DB_USERNAME=Julien
DB_PASSWORD=
DB_DATABASE=duckDatabase
```

3. Configure your local LLM:
   - For development and testing, a local LLM at http://localhost:1234/v1 is used
   - Set `OPENAI_API_BASE` to your LLM endpoint

## Running the Application

### Automated Brand Processing

To process all brands with missing information in sequence:

```bash
python main.py --batch-size 5 --model mistral --env dev
```

Options:
- `--batch-size`: Number of brands to process in one run (default: 5)
- `--model`: LLM model to use (default: mistral)
- `--temperature`: Temperature for LLM generation (default: 0.1)
- `--env`: Environment to run in (dev, test, prod) (default: dev)

### Command-Line Interface

You can also use the CLI for individual operations:

#### Process a specific brand

```bash
python cli.py process "Brand Name" --fields parentCompany brandOrigin
```

Options:
- `--fields`: Specific fields to process (optional, processes all fields if not specified)
- `--model`: LLM model to use (default: mistral)
- `--env`: Environment to run in (dev, test, prod) (default: dev)

#### List incomplete brands

```bash
python cli.py list --limit 10 --field parentCompany
```

Options:
- `--limit`: Maximum number of brands to list (default: 10)
- `--field`: Specific field to check for incompleteness (optional)
- `--env`: Environment to run in (dev, test, prod) (default: dev)

## Testing

To run the agent test which looks up information for a test brand:

```bash
python test_agent.py
```

This will test:
1. Parent company lookup
2. Logo search
3. Brand origin lookup
4. Similar brands lookup

## Modules

- `app/agent.py`: BrandLookupAgent for querying LLMs
- `app/models.py`: Database models using SQLAlchemy
- `app/prompts.py`: Prompt templates for LLM queries
- `app/logo_search.py`: Direct logo search functionality
- `app/processor.py`: Sequential field processing logic
- `app/db_service.py`: Database service functions
- `main.py`: Main application entry point
- `cli.py`: Command-line interface
- `test_agent.py`: Test script for agent functionality
