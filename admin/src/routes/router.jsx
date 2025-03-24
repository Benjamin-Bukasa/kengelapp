// src/routes/router.jsx
import { createBrowserRouter } from "react-router-dom";
import Layout from "../components/Layout";
import Login from "../pages/Login";
// import App from "../App";
import Dashboard from "../pages/Dashboard";


const router = createBrowserRouter([
  
  {
    path: "/login",
    element: <Login />,
  },
  {
    element: <Layout />, // Layout avec Sidebar et RightBar
    children: [
      {
        path:"/dashboard",
        element:<Dashboard/>
      },
    ],
  },
]);

export default router;
