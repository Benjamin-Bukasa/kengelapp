import { useEffect } from "react";
import { useNavigate } from "react-router-dom";
import useAuthStore from "../store/authStore";

const RedirectHome = () => {
  const { token } = useAuthStore();
  const navigate = useNavigate();

  useEffect(() => {
    if (token) {
      navigate("/dashboard");
    } else {
      navigate("/login");
    }
  }, [token, navigate]);

  return null;
};

export default RedirectHome;
