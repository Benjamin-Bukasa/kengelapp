// src/main.jsx
import React from "react";
import ReactDOM from "react-dom/client";
import { RouterProvider } from "react-router-dom";
import router from "./routes/router";
import './index.css'
import { GoogleOAuthProvider } from '@react-oauth/google';

ReactDOM.createRoot(document.getElementById("root")).render(
  <GoogleOAuthProvider clientId="826213663738-ha44d1vivqq275jl8sh29m1v701103g6.apps.googleusercontent.com">
  <React.StrictMode>
    <RouterProvider router={router} />
  </React.StrictMode>
  </GoogleOAuthProvider>
);
