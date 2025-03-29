export interface BrandLiteracy {
  id: string;
  name: string;
  parentCompany: string;
  brandOrigin: string;
  logoUrl: string | null;
  similarBrandsEu: string | null;
  productFamily: string | null;
  totalEmployees: string | null;
  totalEmployeesSource: string | null;
  employeesUS: string | null;
  employeesUSSource: string | null;
  economicImpact: string | null;
  economicImpactSource: string | null;
  factoryInFrance: boolean | null;
  factoryInFranceSource: string | null;
  factoryInEU: boolean | null;
  factoryInEUSource: string | null;
  frenchFarmer: boolean | null;
  frenchFarmerSource: string | null;
  euFarmer: boolean | null;
  euFarmerSource: string | null;
  createdAt: string | null;
  updatedAt: string | null;
  isEnabled: boolean;
  isError: boolean;
}
