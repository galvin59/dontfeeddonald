import { Request, Response } from "express";
import { Like } from "typeorm";
import { AppDataSource } from "../config/database";
import { BrandLiteracy } from "../entity/BrandLiteracy";

// Repository for BrandLiteracy
const brandLiteracyRepository = AppDataSource.getRepository(BrandLiteracy);

/**
 * Search for brands by name
 * Returns an array of results with name, logo, and id
 */
export const lookupBrands = async (req: Request, res: Response): Promise<void> => {
  try {
    const { query } = req.query;
    
    if (!query || typeof query !== "string") {
      res.status(400).json({ error: "Query parameter is required" });
      return;
    }

    const brands = await brandLiteracyRepository.find({
      where: {
        name: Like(`%${query}%`)
      },
      select: ["id", "name", "logoUrl"]
    });

    res.status(200).json(brands);
  } catch (error) {
    console.error("Error looking up brands:", error);
    res.status(500).json({ error: "Internal server error" });
  }
};

/**
 * Get all fields for a specific brand by ID
 */
export const getBrandById = async (req: Request, res: Response): Promise<void> => {
  try {
    const { id } = req.params;
    
    if (!id) {
      res.status(400).json({ error: "ID parameter is required" });
      return;
    }

    const brand = await brandLiteracyRepository.findOne({
      where: { id }
    });

    if (!brand) {
      res.status(404).json({ error: "Brand not found" });
      return;
    }

    // Add a score to the brand data (not stored in the database)
    // TODO: Replace this with the actual scoring algorithm
    // This is where you should implement the final algorithm to calculate the score
    // based on various factors like environmental impact, ethical practices, etc.
    const brandScore = Math.floor(Math.random() * 10) + 1; // Random score between 1 and 10
    
    // Return the brand data with the added score
    res.status(200).json({
      ...brand,
      score: brandScore
    });
  } catch (error) {
    console.error("Error getting brand by ID:", error);
    res.status(500).json({ error: "Internal server error" });
  }
};
