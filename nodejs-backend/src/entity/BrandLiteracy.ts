import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn } from "typeorm";

@Entity("brand_literacy")
export class BrandLiteracy {
  @PrimaryGeneratedColumn("uuid")
  id!: string;

  @Column({ nullable: false })
  name!: string;

  @Column({ type: "text", nullable: true })
  parentCompany!: string | null;

  @Column({ type: "text", nullable: true })
  brandOrigin!: string | null;

  @Column({ type: "text", nullable: true })
  logoUrl!: string | null;

  @Column({ type: "text", nullable: true, name: "productFamily" })
  productFamily!: string | null;

  @Column({ type: "boolean", nullable: true })
  usEmployees!: boolean | null;

  @Column({ type: "text", nullable: true })
  usEmployeesSource!: string | null;

  @Column({ type: "boolean", nullable: true })
  euEmployees!: boolean | null;

  @Column({ type: "text", nullable: true })
  euEmployeesSource!: string | null;

  @Column({ type: "boolean", nullable: true })
  usFactory!: boolean | null;

  @Column({ type: "text", nullable: true })
  usFactorySource!: string | null;

  @Column({ type: "boolean", nullable: true })
  euFactory!: boolean | null;

  @Column({ type: "text", nullable: true })
  euFactorySource!: string | null;

  @Column({ type: "boolean", nullable: true })
  usSupplier!: boolean | null;

  @Column({ type: "text", nullable: true })
  usSupplierSource!: string | null;

  @Column({ type: "boolean", nullable: true })
  euSupplier!: boolean | null;

  @Column({ type: "text", nullable: true })
  euSupplierSource!: string | null;

  @Column({ name: "createdAt", type: "timestamp", nullable: true })
  createdAt!: Date;

  @Column({ name: "updatedAt", type: "timestamp", nullable: true })
  updatedAt!: Date;

  @Column({ name: "isEnabled", nullable: true, default: true })
  isEnabled!: boolean;

  @Column({ name: "isError", nullable: true, default: false })
  isError!: boolean;
}
