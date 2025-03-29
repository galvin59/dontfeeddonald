# Don't Feed Donald - Backoffice

This is the administrative backoffice for the Don't Feed Donald application. It provides an interface for managing brand literacy data.

## Features

- View and manage brand literacy data
- Update logo URLs for brands
- Validate brand information

## Architecture

This backoffice is a client-only Next.js application that communicates directly with the Node.js backend API. It doesn't include any server-side API endpoints of its own, which simplifies the architecture and avoids duplication of functionality.

## Setup

1. Install dependencies:

```bash
npm install
```

2. Configure environment variables:

Copy the `.env.local` file and update the values as needed:

```
# API configuration
NEXT_PUBLIC_API_URL=http://localhost:3000/api

# Admin API key (different from the Flutter app API key)
NEXT_PUBLIC_ADMIN_API_KEY=admin_secret_key_for_backoffice
```

3. Run the development server:

```bash
npm run dev
```

4. Open [http://localhost:3000](http://localhost:3000) in your browser to see the backoffice.

## Backend API Endpoints Used

- `GET /api/brand-literacy/admin/all` - Get all brand literacies with pagination
  - Query parameters:
    - `page` - Page number (default: 1)
    - `limit` - Number of items per page (default: 10)
  - Headers:
    - `x-admin-api-key` - Admin API key for authentication

## Development

### Building for Production

```bash
npm run build
npm start
```

### Code Structure

- `/src/app` - Next.js app router pages
- `/src/components` - React components
- `/src/lib` - Utility functions and API client
- `/src/types` - TypeScript type definitions
