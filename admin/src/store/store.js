import { create } from "zustand"

export const useOpen = create((set) => ({
  isOpen: false,
  setIsOpen: (value) => set({ isOpen: value }),
  toggleIsOpen: () => set((state) => ({ isOpen: !state.isOpen })) // fonction toggle pour ouvrir et fermer le Rightbar
}))
