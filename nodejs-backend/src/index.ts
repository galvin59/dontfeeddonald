import "reflect-metadata";
import express from "express";
import cors from "cors";
import helmet from "helmet";
import rateLimit from "express-rate-limit";
import dotenv from "dotenv";
import { initializeDatabase } from "./config/database";
import brandLiteracyRoutes from "./routes/brandLiteracyRoutes";

// Load environment variables
dotenv.config();

// Initialize Express app
const app = express();
const PORT = process.env.PORT || 3000;

// Apply middlewares
app.use(helmet()); // Security headers
app.use(cors()); // Enable CORS
app.use(express.json()); // Parse JSON bodies

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // Limit each IP to 100 requests per windowMs
  standardHeaders: true,
  legacyHeaders: false,
});
app.use(limiter);

// Health check endpoint
app.get("/health", (req, res) => {
  res.status(200).json({ status: "ok" });
});

// API routes
app.use("/api/brands", brandLiteracyRoutes);

// Start the server
const startServer = async () => {
  try {
    // Initialize database connection
    await initializeDatabase();
    
    // Start Express server
    app.listen(PORT, () => {
      console.log(`Server is running on port ${PORT}`);
    });
  } catch (error) {
    console.error("Failed to start server:", error);
    process.exit(1);
  }
};

startServer();
