import axios from "axios";
import { BrandLiteracy } from "../types/brandLiteracy";

// Create an axios instance with default config
const api = axios.create({
  baseURL: process.env.NEXT_PUBLIC_API_URL || "http://localhost:3000/api",
  headers: {
    "Content-Type": "application/json",
  },
});

// Interface for pagination
export interface PaginationParams {
  page: number;
  limit: number;
}

// Interface for pagination response
export interface PaginatedResponse<T> {
  data: T[];
  total: number;
  page: number;
  limit: number;
  totalPages: number;
}

// Get all brand literacies with pagination
export const getAllBrandLiteracies = async (
  params: PaginationParams
): Promise<PaginatedResponse<BrandLiteracy>> => {
  try {
    const response = await api.get("/brands/admin/all", {
      params: {
        page: params.page,
        limit: params.limit,
      },
      headers: {
        "x-admin-api-key": process.env.NEXT_PUBLIC_ADMIN_API_KEY,
      },
    });
    return response.data;
  } catch (error) {
    console.error("Error fetching brand literacies:", error);
    throw error;
  }
};

// Update brand logo URL
export const updateBrandLogo = async (
  id: string,
  logoUrl: string
): Promise<BrandLiteracy> => {
  try {
    const response = await api.put(`/brands/${id}/logo`, 
      { logoUrl },
      {
        headers: {
          "x-admin-api-key": process.env.NEXT_PUBLIC_ADMIN_API_KEY,
        },
      }
    );
    return response.data;
  } catch (error) {
    console.error("Error updating brand logo:", error);
    throw error;
  }
};
