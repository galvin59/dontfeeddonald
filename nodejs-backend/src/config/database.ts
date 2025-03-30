import { DataSource } from "typeorm";
import dotenv from "dotenv";

// Load environment variables
dotenv.config();

export const AppDataSource = new DataSource({
  type: process.env.DB_TYPE as any || "postgres", // Read type from env
  host: process.env.DB_HOST || "localhost",
  port: parseInt(process.env.DB_PORT || "5432"),
  username: process.env.DB_USERNAME || "postgres",
  password: process.env.DB_PASSWORD || "",
  database: process.env.DB_DATABASE || "duckDatabase",
  synchronize: true, // Enable synchronization to align schema with model
  logging: true, // Enable SQL query logging
  ssl: process.env.DB_SSL === "true", // Read SSL setting from env
  entities: ["dist/entity/**/*.js"],
  subscribers: [],
  migrations: [],
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
