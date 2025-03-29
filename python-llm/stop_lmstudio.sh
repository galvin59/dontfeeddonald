#!/bin/bash

# Script to provide instructions for stopping the LM Studio API server through the GUI

echo "To stop the LM Studio API server:"
echo ""
echo "1. Open LM Studio application (if not already open)"
echo "2. Go to Settings (gear icon)"
echo "3. Disable 'Local Server' option"
echo "4. Click 'Apply' or 'Save'"
echo ""
echo "Alternatively, you can simply close the LM Studio application."

lms server stop

# Check if the API server is still accessible
if curl -s -o /dev/null -w "%{http_code}" http://localhost:1234/v1/models | grep -q "200"; then
    echo ""
    echo "⚠️ Note: The LM Studio API server is still accessible at http://localhost:1234/v1"
    echo "Please follow the instructions above to properly disable it."
else
    echo ""
    echo "✅ The LM Studio API server is not accessible at http://localhost:1234/v1"
    echo "It appears to be already stopped."
fi
