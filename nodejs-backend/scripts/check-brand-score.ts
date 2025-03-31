import "reflect-metadata";
import { AppDataSource } from "../src/config/database";
import { BrandLiteracy } from "../src/entity/BrandLiteracy";
import { calculateBrandScore } from "../src/utils/scoring";

async function checkBrandScore(brandId: string) {
  try {
    console.log("Initializing database connection...");
    // Ensure TypeORM reflects changes in entities and loads metadata correctly
    // This might require specific configuration or ts-node-dev setup if issues persist
    await AppDataSource.initialize();
    console.log("Database connection established.");

    const brandRepository = AppDataSource.getRepository(BrandLiteracy);
    console.log(`Fetching brand with ID: ${brandId}...`);
    const brand = await brandRepository.findOne({ where: { id: brandId } });

    if (!brand) {
      console.error(`Brand with ID ${brandId} not found.`);
      await AppDataSource.destroy();
      console.log("Database connection closed.");
      process.exit(1);
    }

    console.log("\n===== Raw Database Response =====");
    console.log(JSON.stringify(brand, null, 2));

    console.log(`\n===== Brand Information: ${brand.name} =====`);
    console.log(`ID: ${brand.id}`);
    console.log(`Origin: ${brand.brandOrigin || "Unknown"}`);
    console.log(`US Factory: ${brand.usFactory === null ? "Unknown" : brand.usFactory}`);
    console.log(`EU Factory: ${brand.euFactory === null ? "Unknown" : brand.euFactory}`);
    console.log(`US Employees: ${brand.usEmployees === null ? "Unknown" : brand.usEmployees}`);
    console.log(`EU Employees: ${brand.euEmployees === null ? "Unknown" : brand.euEmployees}`);
    console.log(`US Supplier: ${brand.usSupplier === null ? "Unknown" : brand.usSupplier}`);
    console.log(`EU Supplier: ${brand.euSupplier === null ? "Unknown" : brand.euSupplier}`);

    // Calculate the score using the shared utility function
    const scoreDetails = calculateBrandScore(brand);

    console.log("\n===== Score Calculation =====");
    console.log(`1. Origin: ${scoreDetails.originExplanation}`);
    console.log(`2. Factory: ${scoreDetails.factoryExplanation}`);
    console.log(`3. Employees: ${scoreDetails.employeeExplanation}`);
    console.log(`4. Suppliers: ${scoreDetails.supplierExplanation}`);

    console.log("\n===== Score Breakdown =====");
    console.log(`Origin Score: ${scoreDetails.originScore}/40`);
    console.log(`Factory Score: ${scoreDetails.factoryScore}/20`);
    console.log(`Employee Score: ${scoreDetails.employeeScore}/20`);
    console.log(`Supplier Score: ${scoreDetails.supplierScore}/20`);
    console.log(`Total Score: ${scoreDetails.totalScore}/100`);

  } catch (error) {
    console.error("Error during script execution:", error);
    process.exit(1);
  } finally {
    if (AppDataSource.isInitialized) {
      await AppDataSource.destroy();
      console.log("Database connection closed.");
    }
  }
}

// Get brand ID from command line arguments
const brandId = process.argv[2];
if (!brandId) {
  console.error("Please provide a brand ID as a command line argument.");
  console.log("Usage: ts-node scripts/check-brand-score.ts <brandId>");
  process.exit(1);
}

checkBrandScore(brandId);
