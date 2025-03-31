import React from 'react'
import Sidebar from "./Sidebar"
import Rightbar from "./RightBar"
import { Outlet } from "react-router-dom"
import Navbar from './Navbar'

const Layout = () => {
  return (
    <div className="flex h-screen overflow-hidden">
      
      {/* Sidebar avec comportement open/close */}
      <Sidebar />

      {/* Contenu principal scrollable */}
      <main className="flex-1 overflow-y-auto no-scrollbar flex flex-col">
        {/* Navbar sticky */}
        <div className="sticky top-0 z-10">
          <Navbar />
        </div>
        
        {/* Contenu défilable */}
        <div className="flex-1 p-4 overflow-y-auto no-scrollbar">
          <Outlet />
        </div>
      </main>

      {/* Rightbar avec isOpen depuis store */}
      <Rightbar />
    </div>
  )
}

export default Layout
