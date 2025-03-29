import { Express } from "express-serve-static-core";

declare global {
  namespace Express {
    interface Request {
      // You can add custom properties to the Request object here if needed
    }
  }
}
