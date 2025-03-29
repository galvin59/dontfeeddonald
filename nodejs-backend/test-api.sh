#!/bin/bash

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

# Test the lookup endpoint with API key
echo "Testing lookup endpoint with API key..."
curl -s -H "X-API-Key: dont-feed-donald-api-key" "http://localhost:3000/api/brands/lookup?query=act" | jq

# Test the lookup endpoint without API key (should fail)
echo "Testing lookup endpoint without API key (should fail)..."
curl -s "http://localhost:3000/api/brands/lookup?query=test" | jq

# Test the get brand by ID endpoint with API key
echo "Testing get brand by ID endpoint with API key..."
curl -s -H "X-API-Key: dont-feed-donald-api-key" "http://localhost:3000/api/brands/71414947-e16b-471a-9687-a2175acf333b" | jq

# Kill the server process
echo "Stopping server..."
kill $SERVER_PID

echo "Test completed!"
