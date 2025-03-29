import { Request, Response, NextFunction } from "express";
import dotenv from "dotenv";

dotenv.config();

export const apiKeyAuth = (req: Request, res: Response, next: NextFunction): void => {
  const apiKey = req.headers["x-api-key"];
  const expectedApiKey = process.env.API_KEY;

  if (!apiKey) {
    res.status(401).json({ error: "API key is required" });
    return;
  }

  if (apiKey !== expectedApiKey) {
    res.status(403).json({ error: "Invalid API key" });
    return;
  }

  next();
};
