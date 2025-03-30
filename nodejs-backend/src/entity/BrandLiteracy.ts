import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn } from "typeorm";

@Entity("brand_literacy")
export class BrandLiteracy {
  @PrimaryGeneratedColumn("uuid")
  id!: string;

  @Column({ nullable: false })
  name!: string;

  @Column({ nullable: false })
  parentCompany!: string;

  @Column({ nullable: false })
  brandOrigin!: string;

  @Column({ nullable: true })
  logoUrl!: string;

  @Column({ nullable: true })
  similarBrandsEu!: string;

  @Column({ nullable: true })
  productFamily!: string;

  @Column({ nullable: true })
  totalEmployees!: string;

  @Column({ nullable: true })
  totalEmployeesSource!: string;

  @Column({ type: "boolean", nullable: true })
  employeesUS!: boolean | null;

  @Column({ nullable: true })
  employeesUSSource!: string;

  @Column({ type: "boolean", nullable: true })
  employeesEU!: boolean | null;

  @Column({ nullable: true })
  economicImpact!: string;

  @Column({ nullable: true })
  economicImpactSource!: string;

  @Column({ nullable: true })
  factoryInFrance!: boolean;

  @Column({ nullable: true })
  factoryInFranceSource!: string;

  @Column({ nullable: true })
  factoryInEU!: boolean;

  @Column({ nullable: true })
  factoryInEUSource!: string;

  @Column({ type: "boolean", nullable: true })
  factoryInUS!: boolean | null;

  @Column({ nullable: true })
  frenchFarmer!: boolean;

  @Column({ nullable: true })
  frenchFarmerSource!: string;

  @Column({ nullable: true })
  euFarmer!: boolean;

  @Column({ nullable: true })
  euFarmerSource!: string;

  @Column({ type: "boolean", nullable: true })
  farmerUS!: boolean | null;

  @Column({ name: "createdAt", type: "timestamp", nullable: true })
  createdAt!: Date;

  @Column({ name: "updatedAt", type: "timestamp", nullable: true })
  updatedAt!: Date;

  @Column({ name: "isEnabled", nullable: true, default: true })
  isEnabled!: boolean;

  @Column({ name: "isError", nullable: true, default: false })
  isError!: boolean;
}
