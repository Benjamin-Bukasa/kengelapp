// src/routes/router.jsx
import { createBrowserRouter } from "react-router-dom";
import Layout from "../components/Layout";
import Login from "../pages/Login";
import Dashboard from "../pages/Dashboard";
import Users from "../pages/Users";
import Schools from "../pages/Schools";
import Pupils from "../pages/Pupils";
import Parents from "../pages/Parents";
import Messages from "../pages/Messages";
import ProtectedRoute from "./ProtectedRoute";
import RedirectHome from "./RedirectHome";

const router = createBrowserRouter([
  {
    path:"/",
    element: <RedirectHome />,
  },
  {
    path: "/login",
    element: <Login />,
  },
  {
    element: (
      <ProtectedRoute>
        <Layout />
      </ProtectedRoute>
    ),
    children: [
      {
        path: "/dashboard",
        element: <Dashboard />,
      },
      {
        path: "/users",
        element: <Users />,
      },
      {
        path: "/schools",
        element: <Schools />,
      },
      {
        path: "/pupils",
        element: <Pupils />,
      },
      {
        path: "/parents",
        element: <Parents />,
      },
      {
        path: "/messages",
        element: <Messages />,
      },
    ],
  },
]);

export default router;
