import { create } from 'zustand';

const useAuthStore = create((set) => ({
  token: localStorage.getItem("token") || null,
  user: JSON.parse(localStorage.getItem("currentUser")) || null,

  login: (token, user) => {
    localStorage.setItem("token", token);
    localStorage.setItem("currentUser", JSON.stringify(user));
    set({ token, user });
  },

  logout: () => {
    localStorage.removeItem("token");
    localStorage.removeItem("currentUser");
    set({ token: null, user: null });
  }
}));

export default useAuthStore;
