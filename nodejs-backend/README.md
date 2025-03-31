# Brand Lookup Tool - Node.js Backend

This is the Node.js backend for the Brand Lookup Tool, providing API endpoints to access brand information stored in the PostgreSQL database.

## Features

- **TypeORM Integration**: Connects to the same PostgreSQL database as the Python backend
- **RESTful API**: Provides endpoints for brand lookup and detailed information
- **Security**: API key authentication, rate limiting, and security headers
- **TypeScript**: Fully typed codebase for better maintainability

## Project Structure

```
nodejs-backend/
├── src/
│   ├── config/        # Configuration files
│   ├── controller/    # API controllers
│   ├── entity/        # TypeORM entities
│   ├── middleware/    # Express middlewares
│   ├── routes/        # API routes
│   └── types/         # TypeScript type definitions
├── .env               # Environment variables (not in git)
├── .env.example       # Example environment variables
├── package.json       # Project dependencies
└── tsconfig.json      # TypeScript configuration
```

## Setup

1. Install dependencies:
```bash
npm install
```

2. Configure your environment:
```bash
# Copy example environment file
cp .env.example .env

# Edit .env with your database credentials and API key
```

3. Build the application:
```bash
npm run build
```

4. Start the server:
```bash
# Development mode
npm run dev

# Production mode
npm start
```

## API Endpoints

### Health Check
```
GET /health
```
Returns the status of the API server.

### Brand Lookup
```
GET /api/brands/lookup?query=brandName
```
Returns an array of brands with name, logo, and ID that match the query.

### Get Brand Details
```
GET /api/brands/:id
```
Returns all fields for a specific brand by ID.

## Authentication

All API endpoints (except health check) require an API key to be provided in the `x-api-key` header (lowercase):

```
x-api-key: your-api-key-here
```

The API key value is configured in the `.env` file (`API_KEY=...`).

## Development

To run the server in development mode with hot reloading:
```bash
npm run dev
```

### Testing API Endpoints

A script `test-api.sh` is provided to quickly test the main API endpoints.

**Usage:**
```bash
# Test with default brand ID (hardcoded in script)
./test-api.sh

# Test with a specific brand ID
./test-api.sh <brand_id>

# Example
./test-api.sh b0dfbc7e-d4a1-43fe-97b9-4a0a5e81cfc9
```

**What it does:**

1.  Sources the `.env` file to get the `API_KEY`.
2.  Starts the Node.js server in the background using `npm run dev`.
3.  Waits a few seconds for the server to initialize.
4.  Sends `curl` requests to:
    *   `/health` (no auth needed)
    *   `/api/brands/lookup?query=act` (with API key)
    *   `/api/brands/lookup?query=test` (without API key - should fail)
    *   `/api/brands/<brand_id>` (with API key - uses provided ID or default)
5.  Formats the JSON output using `jq` (requires `jq` to be installed).
6.  Stops the background server process.

## Testing Brand Scores

A utility script is provided to check how a specific brand's score is calculated based on its attributes in the database, using the same logic as the API.

### Prerequisites

- Node.js and npm installed
- Dependencies installed: `npm install`
- `ts-node` installed globally or locally: `npm install -g ts-node` or `npm install --save-dev ts-node`
- TypeScript installed: `npm install --save-dev typescript`
- `.env` file configured with correct database credentials in the project root.

### Usage

Run the script using `ts-node` and provide the brand ID as a command-line argument:

```bash
# From the nodejs-backend directory
ts-node scripts/check-brand-score.ts <brandId>

# Example for Chaussée aux Moines
ts-node scripts/check-brand-score.ts b0dfbc7e-d4a1-43fe-97b9-4a0a5e81cfc9
```

### What It Does

The script will:

1. Connect to the database using TypeORM and credentials from `.env`.
2. Fetch the brand data for the specified ID.
3. Calculate the score using the centralized logic from `src/utils/scoring.ts`.
4. Output the raw brand data.
5. Display a detailed breakdown of the score calculation.

### Score Calculation Breakdown

The brand score (max 100) is based on:

1. **Brand Origin (Max 40 points)**
   - +40: EU country/code (e.g., "France", "FR")
   - +10: US/"United States"
   - +20: Other

2. **Factory Location (Max 20 points)**
   - +20: No US, Yes EU
   - +15: Unknown US, Yes EU
   - +10: Yes US, Yes EU
   - +5: No US, No EU
   - +5: Unknown US, Unknown EU
   - +5: Yes US, Unknown EU
   - +0: Yes US, No EU

3. **Employee Location (Max 20 points)**
   - +20: No US, Yes EU
   - +15: Unknown US, Yes EU
   - +10: Yes US, Yes EU
   - +5: No US, No EU
   - +5: Unknown US, Unknown EU
   - +5: Yes US, Unknown EU
   - +0: Yes US, No EU

4. **Supplier Origin (Max 20 points)**
   - +20: No US, Yes EU
   - +15: Unknown US, Yes EU
   - +10: Yes US, Yes EU
   - +10: No US, No EU
   - +10: Unknown US, Unknown EU
   - +5: Yes US, Unknown EU
   - +0: Yes US, No EU

### Finding Brand IDs

- Query the database: `SELECT id, name FROM brand_literacy ORDER BY name;`
- Use the API: `GET /api/brands`

### Troubleshooting

- Ensure `.env` is correct.
- Verify `ts-node` and `typescript` are installed.
- Check database connectivity.
- Confirm the brand ID exists.
