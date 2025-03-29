import { Request, Response, NextFunction } from "express";
import dotenv from "dotenv";

dotenv.config();

export const adminApiKeyAuth = (req: Request, res: Response, next: NextFunction): void => {
  const apiKey = req.headers["x-admin-api-key"];
  const expectedApiKey = process.env.ADMIN_API_KEY;

  if (!apiKey) {
    res.status(401).json({ error: "Admin API key is required" });
    return;
  }

  if (apiKey !== expectedApiKey) {
    res.status(403).json({ error: "Invalid admin API key" });
    return;
  }

  next();
};
