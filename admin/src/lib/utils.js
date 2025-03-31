// Tremor Raw cx [v0.0.0]

import clsx from "clsx";
import { twMerge } from "tailwind-merge";

export function cx(...args) {
  return twMerge(clsx(...args));
}

// Tremor Raw focusInput [v0.0.1]

export const focusInput = [
  // base
  "focus:none",
  // ring color
  "focus:none focus:dark:none",
  // border color
  "focus:border-none focus:dark:border-none",
];

// Tremor Raw focusRing [v0.0.1]

export const focusRing = [
  // base
  "outline outline-offset-0 outline-0 focus-visible:outline-0",
  // outline color
  "outline-0 dark:outline-none-500",
];

// Tremor Raw hasErrorInput [v0.0.1]

export const hasErrorInput = [
  // base
  "ring-2",
  // border color
  "border-red-500 dark:border-red-700",
  // ring color
  "ring-red-200 dark:ring-red-700/30",
];
