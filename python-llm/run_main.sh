#!/bin/bash

# Set the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Check if virtual environment exists, if not create it
if [ ! -d "venv" ]; then
    echo "Creating virtual environment..."
    python3 -m venv venv
    
    # Activate virtual environment
    source venv/bin/activate
    
    # Install requirements if requirements.txt exists
    if [ -f "requirements.txt" ]; then
        echo "Installing requirements..."
        pip install -r requirements.txt
    else
        echo "Warning: requirements.txt not found. You may need to install dependencies manually."
        # Install common packages that might be needed
        pip install langchain langchain_community langchain_core pydantic
    fi
else
    # Activate virtual environment
    source venv/bin/activate
fi

# Run the Python script with all arguments passed to this script
echo "Running main.py with arguments: $@"
python main.py "$@"

# Deactivate virtual environment
deactivate
