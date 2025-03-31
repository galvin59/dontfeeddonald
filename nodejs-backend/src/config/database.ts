import { DataSource } from "typeorm";
import dotenv from "dotenv";
import path from "path"; // Import path module

// Load environment variables
dotenv.config();

// Determine if running in production (compiled JS) or development (TS)
// Render sets NODE_ENV to 'production' by default
const isProduction = process.env.NODE_ENV === "production";

export const AppDataSource = new DataSource({
  type: process.env.DB_TYPE as any || "postgres", // Read type from env
  host: process.env.DB_HOST || "localhost",
  port: parseInt(process.env.DB_PORT || "5432"),
  username: process.env.DB_USERNAME || "postgres",
  password: process.env.DB_PASSWORD || "",
  database: process.env.DB_DATABASE || "duckDatabase",
  synchronize: false, // IMPORTANT: Disable synchronize for production!
  logging: isProduction ? false : true, // Disable verbose logging in production
  ssl: process.env.DB_SSL === "true", // Read SSL setting from env
  // Adjust paths based on environment
  entities: [
    isProduction
      ? path.join(__dirname, "..", "entity", "**", "*.js") // Path relative to dist/config/database.js
      : path.join(__dirname, "..", "entity", "**", "*.ts") // Path relative to src/config/database.ts
  ],
  subscribers: [
    isProduction
      ? path.join(__dirname, "..", "subscriber", "**", "*.js")
      : path.join(__dirname, "..", "subscriber", "**", "*.ts")
  ],
  migrations: [
    isProduction
      ? path.join(__dirname, "..", "migration", "**", "*.js")
      : path.join(__dirname, "..", "migration", "**", "*.ts")
  ],
});

// Initialize the database connection
export const initializeDatabase = async (): Promise<void> => {
  try {
    await AppDataSource.initialize();
    console.log("Database connection established successfully");
  } catch (error) {
    console.error("Error during database connection:", error);
    throw error;
  }
};
