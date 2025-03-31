import React from 'react'
import { useState } from 'react'
import Ads from './Sidebar/ads'
import { Link } from 'react-router-dom'
import logo from "../images/logoKengelapp.png"
import { 
  House, 
  CircleChevronLeft,
  CircleChevronRight,
  UsersRound,
  School,
  GraduationCap,
  ContactRound,
  MessageSquareMore
} from 'lucide-react'
// import Button from './Button'

const Sidebar = () => {

  const [open, setOpen] = useState(true)
  

  const handleClick = ()=>{
    setOpen(!open)
  }
  

  return (
    <div className={`${open?"w-64":"w-16"}z-10 flex flex-col justify-between gap-4 h-screen border border-r-grey-200 transition-all duration-300 font-poppins `}>
      <div className="">
        <div className="px-5 py-4"><span className="font-bold text-xl text-blue-600">{open ?"Kengelapp"  : "K"}</span></div>
        <ul className="flex flex-col gap-4 py-5 text-zinc-700">
          <li className=''><Link to={"/dashboard"} className={`flex items-center gap-4 ${open?"px-3":"justify-center gap-1"} py-3 hover:bg-blue-100 font-medium hover:text-blue-600 transition`} ><House size={20}/><span>{open && "Dashboard"}</span></Link></li>

          <li className=''><Link to={"/users"} className={`flex items-center gap-4 ${open?"px-3":"px-1 justify-center gap-1"} py-3 hover:bg-blue-100 font-medium hover:text-blue-600 transition`} ><UsersRound size={20}/><span>{open && "Utilisateurs"}</span></Link></li>

          <li className=''><Link to={"/schools"} className={`flex items-center gap-4 ${open?"px-3":"px-1 justify-center gap-1"} py-3 hover:bg-blue-100 font-medium hover:text-blue-600 transition`} ><School size={20}/><span>{open && "Ecoles"}</span></Link></li>

          <li className=''><Link to={"/pupils"} className={`flex items-center gap-4 ${open?"px-3":"px-1 justify-center gap-1"} py-3 hover:bg-blue-100 font-medium hover:text-blue-600 transition`} ><GraduationCap size={20}/><span>{open && "Eléves"}</span></Link></li>

          <li className=''><Link to={"/parents"} className={`flex items-center gap-4 ${open?"px-3":"px-1 justify-center gap-1"} py-3 hover:bg-blue-100 font-medium hover:text-blue-600 transition`} ><ContactRound size={20}/><span>{open && "Parents"}</span></Link></li>

          <li className=''><Link to={"/messages"} className={`flex items-center gap-4 ${open?"px-3":"px-1 justify-center gap-1"} py-3 hover:bg-blue-100 font-medium hover:text-blue-600 transition`} ><MessageSquareMore size={20}/><span>{open && "Messages"}</span></Link></li>

        </ul>
      </div>
      <button onClick={handleClick} className={`fixed ${open ? "left-60":"left-10"} top-20 w-7 h-7 flex items-center justify-center rounded-full bg-blue-600 text-white transition-all duration-300`}>
            {
            open?
            <CircleChevronLeft size={14}/>:
            <CircleChevronRight size={14}/>
            }
          </button>
          
        {open && <Ads/>}
    </div>
  )
}

export default Sidebar
