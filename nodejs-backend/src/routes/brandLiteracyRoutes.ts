import { Router } from "express";
import { lookupBrands, getBrandById, getAllBrandLiteracies, updateBrandLogoUrl } from "../controller/brandLiteracyController";
import { apiKeyAuth } from "../middleware/apiKeyAuth";
import { adminApiKeyAuth } from "../middleware/adminApiKeyAuth";

const router = Router();

// Lookup endpoint - returns array of results with name, logo and id
router.get("/lookup", apiKeyAuth, lookupBrands);

// Admin route: Get all brand literacies with pagination
router.get("/admin/all", adminApiKeyAuth, getAllBrandLiteracies);

// Admin route: Update brand logo URL
router.put("/:id/logo", adminApiKeyAuth, updateBrandLogoUrl);

// Get all fields for a specific brand by ID
router.get("/:id", apiKeyAuth, getBrandById);

export default router;
