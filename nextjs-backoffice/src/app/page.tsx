"use client";

import { useState, useEffect, useCallback } from "react";
import { BrandLiteracy } from "../types/brandLiteracy";
import { getAllBrandLiteracies, PaginatedResponse } from "../lib/api";
import BrandLiteracyTable from "../components/BrandLiteracyTable";
import Pagination from "../components/Pagination";

export default function Home() {
  const [brandLiteracies, setBrandLiteracies] = useState<BrandLiteracy[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [pagination, setPagination] = useState({
    page: 1,
    limit: 50,
    total: 0,
    totalPages: 0,
  });

  const fetchBrandLiteracies = useCallback(async () => {
    try {
      setLoading(true);
      const response: PaginatedResponse<BrandLiteracy> = await getAllBrandLiteracies({
        page: pagination.page,
        limit: pagination.limit,
      });
      
      setBrandLiteracies(response.data);
      setPagination({
        ...pagination,
        total: response.total,
        totalPages: response.totalPages,
      });
      setError(null);
    } catch (err: any) {
      console.error("Error fetching brand literacies:", err);
      let errorMessage = "Failed to load brand literacies";
      
      // Add more specific error information if available
      if (err.response) {
        // The request was made and the server responded with a status code
        // that falls out of the range of 2xx
        errorMessage += `: ${err.response.status} ${err.response.statusText}`;
        if (err.response.data && err.response.data.error) {
          errorMessage += ` - ${err.response.data.error}`;
        }
      } else if (err.request) {
        // The request was made but no response was received
        errorMessage += ": No response from server. Please check if the backend is running.";
      } else {
        // Something happened in setting up the request that triggered an Error
        errorMessage += `: ${err.message}`;
      }
      
      setError(errorMessage);
    } finally {
      setLoading(false);
    }
  }, [pagination.page, pagination.limit]);

  useEffect(() => {
    fetchBrandLiteracies();
  }, [fetchBrandLiteracies]);

  const handlePageChange = (newPage: number) => {
    setPagination({
      ...pagination,
      page: newPage,
    });
  };

  const handleBrandUpdate = (updatedBrand: BrandLiteracy) => {
    setBrandLiteracies((prevBrands) =>
      prevBrands.map((brand) =>
        brand.id === updatedBrand.id ? updatedBrand : brand
      )
    );
  };

  return (
    <main className="min-h-screen p-8">
      <h1 className="text-3xl font-bold mb-6">Brand Literacy Management</h1>
      
      {error && (
        <div className="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-4">
          <p className="font-bold">Error:</p>
          <p>{error}</p>
          <div className="mt-2">
            <button 
              onClick={fetchBrandLiteracies} 
              className="bg-red-500 hover:bg-red-700 text-white font-bold py-1 px-3 rounded text-sm"
            >
              Retry
            </button>
          </div>
        </div>
      )}
      
      {loading ? (
        <div className="flex justify-center items-center h-64">
          <div className="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-blue-500"></div>
        </div>
      ) : (
        <>
          {brandLiteracies && brandLiteracies.length > 0 && (
            <BrandLiteracyTable 
              brandLiteracies={brandLiteracies} 
              onBrandUpdate={handleBrandUpdate} 
            />
          )}
          
          <div className="mt-6">
            <Pagination
              currentPage={pagination.page}
              totalPages={pagination.totalPages}
              onPageChange={handlePageChange}
            />
          </div>
        </>
      )}
    </main>
  );
}
