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

All API endpoints (except health check) require an API key to be provided in the `X-API-Key` header:

```
X-API-Key: your-api-key-here
```

## Development

To run the server in development mode with hot reloading:
```bash
npm run dev
```

To test the API endpoints:
```bash
./test-api.sh
```
