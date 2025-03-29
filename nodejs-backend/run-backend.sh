#!/bin/bash

# Print environment information
echo "🔍 Checking environment..."
echo "Current directory: $(pwd)"

# Check if .env exists
if [ -f ".env" ]; then
  echo "✅ .env file found"
else
  echo "⚠️ Warning: .env file not found. Make sure your environment variables are set correctly."
fi

# Install dependencies if needed
if [ ! -d "node_modules" ]; then
  echo "📦 Installing dependencies..."
  npm install
fi

# Check if the admin endpoint is in the TypeScript source
if grep -q "admin/all" "src/routes/brandLiteracyRoutes.ts"; then
  echo "✅ Admin endpoint found in TypeScript source"
else
  echo "⚠️ Warning: Admin endpoint not found in TypeScript source. The admin API may not work correctly."
fi

# Recompile TypeScript code
echo "🔄 Recompiling TypeScript code..."
npm run build

# Check if the admin endpoint is compiled
if grep -q "admin/all" "dist/routes/brandLiteracyRoutes.js"; then
  echo "✅ Admin endpoint successfully compiled"
else
  echo "❌ Error: Admin endpoint not found in compiled code. Check for compilation errors."
  exit 1
fi

# Start the backend
echo "🚀 Starting Node.js backend..."
npm start
