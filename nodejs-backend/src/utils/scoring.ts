import { BrandLiteracy } from "../entity/BrandLiteracy";

// Define EU countries for origin check
const EU_COUNTRIES = [
  "Austria", "Belgium", "Bulgaria", "Croatia", "Republic of Cyprus", "Czech Republic",
  "Denmark", "Estonia", "Finland", "France", "Germany", "Greece", "Hungary",
  "Ireland", "Italy", "Latvia", "Lithuania", "Luxembourg", "Malta", "Netherlands",
  "Poland", "Portugal", "Romania", "Slovakia", "Slovenia", "Spain", "Sweden"
];

// EU country codes for origin check
const EU_COUNTRY_CODES = [
  "AT", "BE", "BG", "HR", "CY", "CZ",
  "DK", "EE", "FI", "FR", "DE", "GR", "HU",
  "IE", "IT", "LV", "LT", "LU", "MT", "NL",
  "PL", "PT", "RO", "SK", "SI", "ES", "SE"
];

/**
 * Calculates the score for a brand based on its attributes
 * @param brand The brand literacy object
 * @returns An object containing the final score and detailed breakdown
 */
export function calculateBrandScore(brand: BrandLiteracy) {
  const scoreDetails = {
    originScore: 0,
    factoryScore: 0,
    employeeScore: 0,
    supplierScore: 0,
    totalScore: 0,
    originExplanation: "",
    factoryExplanation: "",
    employeeExplanation: "",
    supplierExplanation: ""
  };

  // 1. Brand Origin Contribution (Max 40 points)
  const origin = brand.brandOrigin ? brand.brandOrigin.toUpperCase() : "UNKNOWN";
  
  if (EU_COUNTRIES.some(country => country.toUpperCase() === origin) || 
      EU_COUNTRY_CODES.some(code => code.toUpperCase() === origin)) {
    scoreDetails.originScore = 40;
    scoreDetails.originExplanation = `Origin is ${brand.brandOrigin} (EU country): +40 points`;
  } else if (origin === "UNITED STATES" || origin === "US") {
    scoreDetails.originScore = 10;
    scoreDetails.originExplanation = `Origin is United States: +10 points`;
  } else {
    scoreDetails.originScore = 20;
    scoreDetails.originExplanation = `Origin is ${brand.brandOrigin || 'Unknown'} (non-EU, non-US): +20 points`;
  }

  // 2. Factory Location Contribution (Max 20 points)
  const factoryUS = brand.usFactory;
  const factoryEU = brand.euFactory;
  
  if (factoryUS === false && factoryEU === true) {
    scoreDetails.factoryScore = 20;
    scoreDetails.factoryExplanation = "No US factory, Yes EU factory: +20 points";
  } else if (factoryUS === true && factoryEU === true) {
    scoreDetails.factoryScore = 10;
    scoreDetails.factoryExplanation = "Yes US factory, Yes EU factory: +10 points";
  } else if (factoryUS === false && factoryEU === false) {
    scoreDetails.factoryScore = 5;
    scoreDetails.factoryExplanation = "No US factory, No EU factory: +5 points";
  } else if (factoryUS === true && factoryEU === false) {
    scoreDetails.factoryScore = 0;
    scoreDetails.factoryExplanation = "Yes US factory, No EU factory: +0 points";
  } else if (factoryUS === null && factoryEU === null) {
    scoreDetails.factoryScore = 5;
    scoreDetails.factoryExplanation = "Unknown US factory, Unknown EU factory: +5 points";
  } else if (factoryUS === null && factoryEU === true) {
    scoreDetails.factoryScore = 15;
    scoreDetails.factoryExplanation = "Unknown US factory, Yes EU factory: +15 points";
  } else if (factoryUS === true && factoryEU === null) {
    scoreDetails.factoryScore = 5;
    scoreDetails.factoryExplanation = "Yes US factory, Unknown EU factory: +5 points";
  } else {
    scoreDetails.factoryScore = 5;
    scoreDetails.factoryExplanation = `Other factory combination (US: ${factoryUS}, EU: ${factoryEU}): +5 points`;
  }

  // 3. Employee Location Contribution (Max 20 points)
  const employeesUS = brand.usEmployees;
  const employeesEU = brand.euEmployees;

  if (employeesUS === false && employeesEU === true) {
    scoreDetails.employeeScore = 20;
    scoreDetails.employeeExplanation = "No US employees, Yes EU employees: +20 points";
  } else if (employeesUS === true && employeesEU === true) {
    scoreDetails.employeeScore = 10;
    scoreDetails.employeeExplanation = "Yes US employees, Yes EU employees: +10 points";
  } else if (employeesUS === false && employeesEU === false) {
    scoreDetails.employeeScore = 5;
    scoreDetails.employeeExplanation = "No US employees, No EU employees: +5 points";
  } else if (employeesUS === true && employeesEU === false) {
    scoreDetails.employeeScore = 0;
    scoreDetails.employeeExplanation = "Yes US employees, No EU employees: +0 points";
  } else if (employeesUS === null && employeesEU === null) {
    scoreDetails.employeeScore = 5;
    scoreDetails.employeeExplanation = "Unknown US employees, Unknown EU employees: +5 points";
  } else if (employeesUS === null && employeesEU === true) {
    scoreDetails.employeeScore = 15;
    scoreDetails.employeeExplanation = "Unknown US employees, Yes EU employees: +15 points";
  } else if (employeesUS === true && employeesEU === null) {
    scoreDetails.employeeScore = 5;
    scoreDetails.employeeExplanation = "Yes US employees, Unknown EU employees: +5 points";
  } else {
    scoreDetails.employeeScore = 5;
    scoreDetails.employeeExplanation = `Other employee combination (US: ${employeesUS}, EU: ${employeesEU}): +5 points`;
  }

  // 4. Supplier (Farmer) Origin Contribution (Max 20 points)
  const farmerUS = brand.usSupplier;
  const farmerEU = brand.euSupplier;

  if (farmerUS === false && farmerEU === true) {
    scoreDetails.supplierScore = 20;
    scoreDetails.supplierExplanation = "No US supplier, Yes EU supplier: +20 points";
  } else if (farmerUS === true && farmerEU === true) {
    scoreDetails.supplierScore = 10;
    scoreDetails.supplierExplanation = "Yes US supplier, Yes EU supplier: +10 points";
  } else if (farmerUS === false && farmerEU === false) {
    scoreDetails.supplierScore = 10;
    scoreDetails.supplierExplanation = "No US supplier, No EU supplier: +10 points";
  } else if (farmerUS === true && farmerEU === false) {
    scoreDetails.supplierScore = 0;
    scoreDetails.supplierExplanation = "Yes US supplier, No EU supplier: +0 points";
  } else if (farmerUS === null && farmerEU === null) {
    scoreDetails.supplierScore = 10;
    scoreDetails.supplierExplanation = "Unknown US supplier, Unknown EU supplier: +10 points";
  } else if (farmerUS === null && farmerEU === true) {
    scoreDetails.supplierScore = 15;
    scoreDetails.supplierExplanation = "Unknown US supplier, Yes EU supplier: +15 points";
  } else if (farmerUS === true && farmerEU === null) {
    scoreDetails.supplierScore = 5;
    scoreDetails.supplierExplanation = "Yes US supplier, Unknown EU supplier: +5 points";
  } else {
    scoreDetails.supplierScore = 10;
    scoreDetails.supplierExplanation = `Other supplier combination (US: ${farmerUS}, EU: ${farmerEU}): +10 points`;
  }

  // Calculate total score
  const totalScore = 
    scoreDetails.originScore + 
    scoreDetails.factoryScore + 
    scoreDetails.employeeScore + 
    scoreDetails.supplierScore;
  
  // Ensure score is within 0-100 range
  scoreDetails.totalScore = Math.max(0, Math.min(100, totalScore));

  return scoreDetails;
}
