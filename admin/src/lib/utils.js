// src/lib/utils.js

import { clsx } from "clsx"
import { twMerge } from "tailwind-merge"

/**
 * Combine les classes conditionnelles et merge intelligemment les classes Tailwind
 * @param  {...any} inputs
 * @returns {string} classe CSS finale
 */
export function cn(...inputs) {
  return twMerge(clsx(...inputs))
}
