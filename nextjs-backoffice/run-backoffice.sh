#!/bin/bash

# Print environment information
echo "🔍 Checking environment..."
echo "Current directory: $(pwd)"

# Check if .env.local exists
if [ -f ".env.local" ]; then
  echo "✅ .env.local file found"
  echo "API URL: $(grep NEXT_PUBLIC_API_URL .env.local | cut -d '=' -f2)"
  echo "Admin API Key: $(grep NEXT_PUBLIC_ADMIN_API_KEY .env.local | cut -d '=' -f2 | sed 's/./*/g')"
else
  echo "❌ .env.local file not found. Creating a default one..."
  cat > .env.local << EOL
# API configuration
NEXT_PUBLIC_API_URL=http://localhost:3000/api

# Admin API key (different from the Flutter app API key)
NEXT_PUBLIC_ADMIN_API_KEY=admin_secret_key_for_backoffice
EOL
  echo "✅ Created default .env.local file"
fi



# Check if the backend is running
echo "\n🔍 Checking if the Node.js backend is running..."
if ! nc -z localhost 3000 &>/dev/null; then
  echo "⚠️ Warning: The Node.js backend doesn't appear to be running on port 3000."
  echo "Make sure to start the backend separately with: cd ../nodejs-backend && npm start"
  echo ""
fi

# Start the Next.js backoffice
echo "\n🚀 Starting Next.js backoffice..."

# Make sure node_modules exists
if [ ! -d "node_modules" ]; then
  echo "📦 Installing dependencies..."
  npm install
fi

# Run the dev server with debugging enabled
echo "\n🌐 Starting development server with debugging enabled..."
NODE_OPTIONS='--inspect' npm run dev
