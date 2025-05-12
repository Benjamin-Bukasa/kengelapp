import { create } from 'zustand';

// Fonction utilitaire pour charger depuis localStorage ou sessionStorage
const getInitialData = () => {
  const token = localStorage.getItem("token") || sessionStorage.getItem("token");
  const user = JSON.parse(localStorage.getItem("currentUser") || sessionStorage.getItem("currentUser")) || null;
  return { token, user };
};

const useAuthStore = create((set) => ({
  ...getInitialData(),

  login: (token, user, rememberMe = true) => {
    const storage = rememberMe ? localStorage : sessionStorage;
    storage.setItem("token", token);
    storage.setItem("currentUser", JSON.stringify(user));
    set({ token, user });
  },

  logout: () => {
    localStorage.removeItem("token");
    localStorage.removeItem("currentUser");
    sessionStorage.removeItem("token");
    sessionStorage.removeItem("currentUser");
    set({ token: null, user: null });
  }
}));

export default useAuthStore;
