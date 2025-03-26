"""Database connection and session management module."""
from sqlalchemy import create_engine, MetaData
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, Session

from app.config import DB_CONFIG

# Build the connection string
if DB_CONFIG["password"]:
    connection_string = f"postgresql://{DB_CONFIG['username']}:{DB_CONFIG['password']}@{DB_CONFIG['host']}:{DB_CONFIG['port']}/{DB_CONFIG['database']}"
else:
    # Handle the case where password is empty
    connection_string = f"postgresql://{DB_CONFIG['username']}@{DB_CONFIG['host']}:{DB_CONFIG['port']}/{DB_CONFIG['database']}"

# Create SQLAlchemy engine
engine = create_engine(connection_string)

# Create session factory
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Create base class for models
Base = declarative_base()

# Metadata object for database operations
metadata = MetaData()

def get_db_session() -> Session:
    """Get a database session.
    
    Returns:
        Session: SQLAlchemy session
    """
    db = SessionLocal()
    try:
        return db
    finally:
        db.close()

def test_connection() -> bool:
    """Test the database connection.
    
    Returns:
        bool: True if connection is successful, False otherwise
    """
    try:
        # Try to connect to the database
        with engine.connect() as connection:
            return True
    except Exception as e:
        print(f"Database connection error: {e}")
        return False
