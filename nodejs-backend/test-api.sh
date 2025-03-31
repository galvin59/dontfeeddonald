#!/bin/bash

# Source the .env file safely
set -a # Automatically export all variables
if [ -f .env ]; then
  source .env
else
  echo "Error: .env file not found!"
  exit 1
fi
set +a # Stop automatically exporting

# Check if API_KEY is set
if [ -z "${API_KEY}" ]; then
  echo "Error: API_KEY not found or empty in .env file!"
  exit 1
fi

# Get Brand ID from command line argument, or use default
BRAND_ID=${1:-71414947-e16b-471a-9687-a2175acf333b} # Use $1 if provided, else default

# Start the server in the background
echo "Starting Node.js server..."
npm run dev &
SERVER_PID=$!

# Give the server time to start
echo "Waiting for server to start..."
sleep 5

# Test the health endpoint
echo "Testing health endpoint..."
curl -s http://localhost:3000/health | jq

# Test the lookup endpoint with API key from .env
echo "Testing lookup endpoint with API key..."
curl -s -H "x-api-key: ${API_KEY}" "http://localhost:3000/api/brands/lookup?query=act" | jq

# Test the lookup endpoint without API key (should fail)
echo "Testing lookup endpoint without API key (should fail)..."
curl -s "http://localhost:3000/api/brands/lookup?query=test" | jq

# Test the get brand by ID endpoint with API key from .env, using the provided or default BRAND_ID
echo "Testing get brand by ID endpoint with API key (ID: ${BRAND_ID})..."
curl -s -H "x-api-key: ${API_KEY}" "http://localhost:3000/api/brands/${BRAND_ID}" | jq

# Kill the server process
echo "Stopping server..."
kill $SERVER_PID

echo "Test completed!"
