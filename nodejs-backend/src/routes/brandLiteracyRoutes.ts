import { Router } from "express";
import { lookupBrands, getBrandById } from "../controller/brandLiteracyController";
import { apiKeyAuth } from "../middleware/apiKeyAuth";

const router = Router();

// Lookup endpoint - returns array of results with name, logo and id
router.get("/lookup", apiKeyAuth, lookupBrands);

// Get all fields for a specific brand by ID
router.get("/:id", apiKeyAuth, getBrandById);

export default router;
