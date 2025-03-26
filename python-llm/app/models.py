"""Database models for the application."""
from sqlalchemy import Column, Integer, String, Text, DateTime, Boolean
from sqlalchemy.sql import func

from app.database import Base

class BrandLiteracy(Base):
    """Model representing a brand and its information.
    
    Maps to the existing brand_literacy table in the database.
    Contains mandatory and optional information about brands,
    including tuples of value/source pairs for various metrics.
    """
    
    __tablename__ = "brand_literacy"
    
    # Primary key
    id = Column(Integer, primary_key=True, index=True)
    
    # Mandatory fields
    name = Column(String(255), index=True, nullable=False)
    brandOrigin = Column(String(2), nullable=False, comment="2 letters international ISO format for country")
    parentCompany = Column(String(255), nullable=False)
    
    # Optional fields
    logoUrl = Column(Text, nullable=True)
    similarBrandsEu = Column(Text, nullable=True)
    productFamily = Column(String(255), nullable=True)
    
    # Value/Source tuples
    totalEmployees = Column(Text, nullable=True)
    totalEmployeesSource = Column(Text, nullable=True)
    employeesUS = Column(Text, nullable=True)
    employeesUSSource = Column(Text, nullable=True)
    economicImpact = Column(Text, nullable=True)
    economicImpactSource = Column(Text, nullable=True)
    
    # Boolean fields with sources
    factoryInFrance = Column(Boolean, nullable=True)
    factoryInFranceSource = Column(Text, nullable=True)
    factoryInEU = Column(Boolean, nullable=True)
    factoryInEUSource = Column(Text, nullable=True)
    frenchFarmer = Column(Boolean, nullable=True)
    frenchFarmerSource = Column(Text, nullable=True)
    euFarmer = Column(Boolean, nullable=True)
    euFarmerSource = Column(Text, nullable=True)

    
    # Metadata fields
    createdAt = Column(DateTime(timezone=True), server_default=func.now())
    updatedAt = Column(DateTime(timezone=True), onupdate=func.now())
    isEnabled = Column(Boolean, default=True)
    isError = Column(Boolean, default=False)
    
    def __repr__(self):
        return f"<BrandLiteracy(name='{self.name}', parentCompany='{self.parentCompany}')>"
