// src/routes/router.jsx
import { createBrowserRouter } from "react-router-dom";
import Layout from "../components/Layout";
import Login from "../pages/Login";
// import App from "../App";
import Dashboard from "../pages/Dashboard";
import Users from "../pages/Users"
import Schools from "../pages/Schools"
import Pupils from "../pages/Pupils"
import Parents from "../pages/Parents"
import Messages from "../pages/Messages"


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
      {
        path:"/users",
        element:<Users/>
      },
      {
        path:"/schools",
        element:<Schools/>
      },
      {
        path:"/pupils",
        element:<Pupils/>
      },
      {
        path:"/parents",
        element:<Parents/>
      },
      {
        path:"/messages",
        element:<Messages/>
      },
    ],
  },
]);

export default router;
