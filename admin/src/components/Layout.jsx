import React from 'react'
import Sidebar from "./Sidebar"
import Rightbar from "./RightBar"
import {Outlet} from "react-router-dom"
import Navbar from './Navbar'

const Layout = () => {
  return (
    <div className="flex">
      <Sidebar/>
      <main className='flex-1'>
        <Navbar/>
        <Outlet/>
      </main>
      <Rightbar/>
    </div>
  )
}

export default Layout
