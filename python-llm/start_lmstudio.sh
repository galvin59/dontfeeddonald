#!/bin/bash

# Script to check if LM Studio API is accessible and provide instructions if it's not
# LM Studio needs to be running with API server enabled through the GUI

echo "Checking LM Studio API server..."
lms server start

# Test if the API server is accessible
if curl -s -o /dev/null -w "%{http_code}" http://localhost:1234/v1/models | grep -q "200"; then
    echo "✅ LM Studio API server is accessible at http://localhost:1234/v1"
    echo "You can now run your application."
    exit 0
else
    echo "❌ LM Studio API server is not accessible at http://localhost:1234/v1"
    echo ""
    echo "Please ensure LM Studio is running and API server is enabled:"
    echo "1. Open LM Studio application"
    echo "2. Go to Settings (gear icon)"
    echo "3. Enable 'Local Server' option"
    echo "4. Set Host to '127.0.0.1' and Port to '1234'"
    echo "5. Click 'Apply' or 'Save'"
    echo ""
    echo "After enabling the API server in LM Studio, run this script again."
    exit 1
fi
