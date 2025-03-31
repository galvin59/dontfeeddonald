"use client";

import React from "react";

interface ProductFamilyFilterProps {
  families: string[];
  selectedFamily: string;
  onFilterChange: (family: string) => void;
}

const ProductFamilyFilter: React.FC<ProductFamilyFilterProps> = ({
  families,
  selectedFamily,
  onFilterChange,
}) => {
  return (
    <div className="flex items-center space-x-2">
      <label htmlFor="productFamilyFilter" className="text-sm font-medium text-gray-700">
        Filter by Product Family:
      </label>
      <select
        id="productFamilyFilter"
        value={selectedFamily}
        onChange={(e) => onFilterChange(e.target.value)}
        className="block w-full max-w-xs pl-3 pr-10 py-2 text-base border-gray-300 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm rounded-md shadow-sm"
      >
        {families.length === 0 ? (
          <option value="All" disabled>Loading families...</option>
        ) : (
          families.map((family) => (
            <option key={family} value={family}>
              {family}
            </option>
          ))
        )}
      </select>
    </div>
  );
};

export default ProductFamilyFilter;
