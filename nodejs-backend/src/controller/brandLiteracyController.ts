import { Request, Response } from "express";
import { ILike } from "typeorm";
import { AppDataSource } from "../config/database";
import { BrandLiteracy } from "../entity/BrandLiteracy";
import { calculateBrandScore } from "../utils/scoring"; // Import the new utility function

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
        name: ILike(`%${query}%`)
      }
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

    const brand = await brandLiteracyRepository.findOne({ where: { id } });

    if (!brand) {
      res.status(404).json({ error: "Brand not found" });
      return;
    }

    // Calculate score using the utility function
    const scoreDetails = calculateBrandScore(brand);

    res.status(200).json({
      ...brand,
      score: scoreDetails.totalScore, // Use the calculated total score
      scoreDetails: {
        origin: scoreDetails.originScore,
        factory: scoreDetails.factoryScore,
        employees: scoreDetails.employeeScore,
        supplier: scoreDetails.supplierScore,
        explanations: {
          origin: scoreDetails.originExplanation,
          factory: scoreDetails.factoryExplanation,
          employees: scoreDetails.employeeExplanation,
          supplier: scoreDetails.supplierExplanation
        }
      }
    });
  } catch (error) {
    console.error("Error getting brand by ID:", error);
    res.status(500).json({ error: "Internal server error" });
  }
};

/**
 * Get all brand literacies with pagination (admin endpoint)
 */
export const getAllBrandLiteracies = async (req: Request, res: Response): Promise<void> => {
  try {
    // Get pagination parameters from query
    const page = parseInt(req.query.page as string) || 1;
    const limit = parseInt(req.query.limit as string) || 10;
    const skip = (page - 1) * limit;

    // Get total count
    const total = await brandLiteracyRepository.count();

    // Get paginated data
    const brandLiteracies = await brandLiteracyRepository.find({
      skip,
      take: limit,
      order: {
        name: "ASC"
      }
    });

    // Calculate total pages
    const totalPages = Math.ceil(total / limit);

    // Return paginated response
    res.status(200).json({
      data: brandLiteracies,
      total,
      page,
      limit,
      totalPages
    });
  } catch (error) {
    console.error("Error fetching all brand literacies:", error);
    res.status(500).json({ error: "Internal server error" });
  }
};

/**
 * Update the logo URL for a specific brand (admin endpoint)
 */
export const updateBrandLogoUrl = async (req: Request, res: Response): Promise<void> => {
  try {
    const { id } = req.params;
    const { logoUrl } = req.body;

    if (!id) {
      res.status(400).json({ error: "ID parameter is required" });
      return;
    }

    if (typeof logoUrl !== "string") {
      res.status(400).json({ error: "logoUrl must be a string" });
      return;
    }

    // Find the brand first to ensure it exists
    const brand = await brandLiteracyRepository.findOne({ where: { id } });
    if (!brand) {
      res.status(404).json({ error: "Brand not found" });
      return;
    }

    // Update the logoUrl
    const result = await brandLiteracyRepository.update(id, { logoUrl });

    if (result.affected === 0) {
      // Should not happen if the findOne check passed, but good practice
      res.status(404).json({ error: "Brand not found or update failed" });
      return;
    }

    // Fetch the updated brand to return it
    const updatedBrand = await brandLiteracyRepository.findOne({ where: { id } });
    res.status(200).json(updatedBrand);

  } catch (error) {
    console.error("Error updating brand logo URL:", error);
    res.status(500).json({ error: "Internal server error" });
  }
};
