"use client";

import { useState, useEffect } from "react";
import { BrandLiteracy } from "../types/brandLiteracy";
import { updateBrandLogo } from "../lib/api";
import Image from "next/image";

interface BrandLiteracyTableProps {
  brandLiteracies: BrandLiteracy[];
  onBrandUpdate: (updatedBrand: BrandLiteracy) => void;
}

export default function BrandLiteracyTable({ brandLiteracies, onBrandUpdate }: BrandLiteracyTableProps) {
  // State to track the logo URL input values
  const [logoUrls, setLogoUrls] = useState<Record<string, string>>({});
  // State to track loading state for each row
  const [loadingStates, setLoadingStates] = useState<Record<string, boolean>>({});
  // State to track error messages for each row
  const [errorMessages, setErrorMessages] = useState<Record<string, string | null>>({});

  // Initialize logoUrls from brandLiteracies on initial render or when brands change
  useEffect(() => {
    const initialLogoUrls: Record<string, string> = {};
    brandLiteracies.forEach((brand) => {
      initialLogoUrls[brand.id] = brand.logoUrl || "";
    });
    setLogoUrls(initialLogoUrls);
  }, [brandLiteracies]);

  // Handle logo URL input change
  const handleLogoUrlChange = (id: string, value: string) => {
    setLogoUrls({
      ...logoUrls,
      [id]: value,
    });
  };

  // Check if URL is valid
  const isValidUrl = (url: string) => {
    if (!url) return false;
    try {
      new URL(url);
      return true;
    } catch (e) {
      return false;
    }
  };

  // Handle validate button click
  const handleValidate = async (id: string) => {
    setLoadingStates({ ...loadingStates, [id]: true });
    setErrorMessages({ ...errorMessages, [id]: null });
    
    const newLogoUrl = logoUrls[id];
    if (!isValidUrl(newLogoUrl)) {
      setErrorMessages({ ...errorMessages, [id]: "Invalid URL format." });
      setLoadingStates({ ...loadingStates, [id]: false });
      return;
    }
    
    try {
      const updatedBrand = await updateBrandLogo(id, newLogoUrl);
      // Update the local state with the new URL from the response
      setLogoUrls({
        ...logoUrls,
        [id]: updatedBrand.logoUrl || "",
      });
      // Notify parent component about the update
      onBrandUpdate(updatedBrand);
      // Optionally show a success message or visual feedback
      console.log(`Successfully updated logo for brand ID: ${id}`);
    } catch (err: any) {
      console.error(`Error validating brand ID ${id}:`, err);
      let message = "Failed to update logo.";
      if (err.response?.data?.error) {
        message += ` ${err.response.data.error}`;
      }
      setErrorMessages({ ...errorMessages, [id]: message });
    } finally {
      setLoadingStates({ ...loadingStates, [id]: false });
    }
  };

  return (
    <div className="overflow-x-auto shadow-md rounded-lg">
      <table className="min-w-full bg-white">
        <thead className="bg-gray-100">
          <tr>
            <th className="py-3 px-4 text-left text-sm font-medium text-gray-700 uppercase tracking-wider">
              Brand Name
            </th>
            <th className="py-3 px-4 text-left text-sm font-medium text-gray-700 uppercase tracking-wider">
              Logo URL
            </th>
            <th className="py-3 px-4 text-left text-sm font-medium text-gray-700 uppercase tracking-wider">
              Logo Preview
            </th>
            <th className="py-3 px-4 text-left text-sm font-medium text-gray-700 uppercase tracking-wider">
              Actions
            </th>
          </tr>
        </thead>
        <tbody className="divide-y divide-gray-200">
          {brandLiteracies.map((brand) => (
            <tr key={brand.id} className="hover:bg-gray-50">
              <td className="py-4 px-4 text-sm text-gray-900">
                {brand.name}
              </td>
              <td className="py-4 px-4 text-sm text-gray-900">
                <input
                  type="text"
                  value={logoUrls[brand.id] || ""}
                  onChange={(e) => handleLogoUrlChange(brand.id, e.target.value)}
                  className="w-full p-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                  placeholder="Enter logo URL"
                  disabled={loadingStates[brand.id]} // Disable input while loading
                />
              </td>
              <td className="py-4 px-4 text-sm text-gray-900">
                {isValidUrl(logoUrls[brand.id]) ? (
                  <div className="relative h-16 w-16">
                    <Image
                      src={logoUrls[brand.id]}
                      alt={`${brand.name} logo`}
                      fill
                      style={{ objectFit: "contain" }}
                      onError={(e) => {
                        // Handle image load error
                        const target = e.target as HTMLImageElement;
                        target.src = "/placeholder-image.png"; // Fallback image
                      }}
                    />
                  </div>
                ) : (
                  <div className="text-gray-400 italic">No valid image URL</div>
                )}
              </td>
              <td className="py-4 px-4 text-sm text-gray-900">
                <button
                  onClick={() => handleValidate(brand.id)}
                  className={`py-2 px-4 rounded-md transition duration-150 ease-in-out text-white ${loadingStates[brand.id] ? "bg-gray-400 cursor-not-allowed" : "bg-blue-500 hover:bg-blue-600"}`}
                  disabled={loadingStates[brand.id] || !isValidUrl(logoUrls[brand.id])}
                >
                  {loadingStates[brand.id] ? "Validating..." : "Validate"}
                </button>
                {errorMessages[brand.id] && (
                  <p className="text-red-500 text-xs mt-1">{errorMessages[brand.id]}</p>
                )}
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
