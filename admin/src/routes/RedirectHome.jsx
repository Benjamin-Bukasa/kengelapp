import { useEffect } from "react";
import { useNavigate } from "react-router-dom";
import useAuthStore from "../store/authStore";
import Loader from "../components/Loader";

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

  return <Loader />; // Show a loader while redirecting
};

export default RedirectHome;
