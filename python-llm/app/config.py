"""Configuration module for loading environment variables."""
import os
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

# Database configuration
DB_CONFIG = {
    "type": os.getenv("DB_TYPE", "postgres"),
    "host": os.getenv("DB_HOST", "localhost"),
    "port": int(os.getenv("DB_PORT", "5432")),
    "username": os.getenv("DB_USERNAME", ""),
    "password": os.getenv("DB_PASSWORD", ""),
    "database": os.getenv("DB_DATABASE", ""),
    "synchronize": os.getenv("DB_SYNCHRONIZE", "true").lower() == "true",
    "ssl": os.getenv("DB_SSL", "false").lower() == "true" # Read DB_SSL
}

# LLM configuration
