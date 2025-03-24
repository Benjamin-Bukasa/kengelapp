import { create } from "zustand"

export const useOpen = create((set) => ({
  isOpen: true,
  setIsOpen: (value) => set({ isOpen: value }), // on met à jour avec un objet
  toggleIsOpen: () => set((state) => ({ isOpen: !state.isOpen })) // une fonction pour toggle
}))
