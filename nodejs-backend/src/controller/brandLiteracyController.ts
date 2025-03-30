import { Request, Response } from "express";
import { ILike } from "typeorm";
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
        name: ILike(`%${query}%`)
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

    // Define EU countries for origin check
    const euCountries = [
      "Austria", "Belgium", "Bulgaria", "Croatia", "Republic of Cyprus", "Czech Republic",
      "Denmark", "Estonia", "Finland", "France", "Germany", "Greece", "Hungary",
      "Ireland", "Italy", "Latvia", "Lithuania", "Luxembourg", "Malta", "Netherlands",
      "Poland", "Portugal", "Romania", "Slovakia", "Slovenia", "Spain", "Sweden"
    ];

    // --- Calculate Brand Score (Algorithm) ---
    let score = 0;

    // 1. Brand Origin Contribution (Max 40 points)
    if (brand.brandOrigin) {
      if (euCountries.includes(brand.brandOrigin)) {
        score += 40; // EU Origin
      } else if (brand.brandOrigin === "United States") {
        score += 10; // US Origin
      } else {
        score += 20; // Other Origin
      }
    } else {
      score += 20; // Unknown Origin treated as 'Other'
    }

    // 2. Factory Location Contribution (Max 20 points)
    // Assumes brand.factoryInUS exists
    const factoryUS = brand.factoryInUS;
    const factoryEU = brand.factoryInEU;

    if (factoryUS === false && factoryEU === true) {
      score += 20;
    } else if (factoryUS === true && factoryEU === true) {
      score += 10;
    } else if (factoryUS === false && factoryEU === false) {
      score += 5;
    } else if (factoryUS === true && factoryEU === false) {
      score += 0;
    } else if (factoryUS === null && factoryEU === null) {
      score += 5; // Both Unknown
    } else if (factoryUS === null && factoryEU === true) {
      score += 15; // US Unknown, EU True
    } else if (factoryUS === true && factoryEU === null) {
      score += 5;  // US True, EU Unknown
    } else {
      // Handle any combinations not explicitly listed (e.g., false/null, null/false)
      // Defaulting to a lower score contribution for uncertainty/missing data
      score += 5;
    }

    // 3. Employee Location Contribution (Max 20 points)
    // Assumes brand.employeesEU exists alongside brand.employeesUS
    const employeesUS = brand.employeesUS; 
    const employeesEU = (brand as any).employeesEU; // Cast as any if field not strongly typed yet

    if (employeesUS === false && employeesEU === true) {
      score += 20;
    } else if (employeesUS === true && employeesEU === true) {
      score += 10;
    } else if (employeesUS === false && employeesEU === false) {
      score += 5;
    } else if (employeesUS === true && employeesEU === false) {
      score += 0;
    } else if (employeesUS === null && employeesEU === null) {
      score += 5; // Both Unknown
    } else if (employeesUS === null && employeesEU === true) {
      score += 15; // US Unknown, EU True
    } else if (employeesUS === true && employeesEU === null) {
      score += 5;  // US True, EU Unknown
    } else {
      score += 5; // Default for other combinations
    }

    // 4. Farmer Origin Contribution (Max 20 points)
    // Assumes brand.farmerUS exists alongside brand.euFarmer
    const farmerUS = (brand as any).farmerUS; // Cast as any if field not strongly typed yet
    const farmerEU = brand.euFarmer;

    if (farmerUS === false && farmerEU === true) {
      score += 20;
    } else if (farmerUS === true && farmerEU === true) {
      score += 10;
    } else if (farmerUS === false && farmerEU === false) {
      score += 10; // Note: false/false is 10 points here, different from factory/employee
    } else if (farmerUS === true && farmerEU === false) {
      score += 0;
    } else if (farmerUS === null && farmerEU === null) {
      score += 10; // Both Unknown
    } else if (farmerUS === null && farmerEU === true) {
      score += 15; // US Unknown, EU True (Inferred logic)
    } else if (farmerUS === true && farmerEU === null) {
      score += 5;  // US True, EU Unknown (Inferred logic)
    } else {
      score += 10; // Default for other combinations
    }

    // Ensure score is within 0-100 range (though algorithm max seems 100)
    const finalScore = Math.max(0, Math.min(100, score));

    // Return the brand data with the added score
    res.status(200).json({
      ...brand,
      score: finalScore
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
