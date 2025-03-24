import React from 'react'
import { useState } from 'react'
import Ads from './Sidebar/ads'
import { Link } from 'react-router-dom'
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

const Sidebar = () => {

  const [open, setOpen] = useState(true)

  const handleClick = ()=>{
    setOpen(!open)
  }
  

  return (
    <div className={`${open?"w-64":"w-16"}fixed flex flex-col justify-between gap-4 min-h-screen border border-r-grey-200 transition-all duration-300 `}>
      <div className="">
        <div className="px-5 py-4"><span className="font-bold text-xl text-blue-600">{open ? "Kengel'app" : "K"}</span></div>
        <ul className="flex flex-col gap-4 py-5 text-zinc-700">
          <li className=''><Link to={"/"} className={`flex items-center gap-4 ${open?"px-3":"px-1 justify-center gap-1"} py-2   hover:bg-blue-100 font-medium hover:text-blue-600 transition`} ><House size={20}/><span>{open && "Dashboard"}</span></Link></li>
          <li className=''><Link to={"/"} className={`flex items-center gap-4 ${open?"px-3":"px-1 justify-center gap-1"} py-2 hover:bg-blue-100 font-medium hover:text-blue-600 transition`} ><UsersRound size={20}/><span>{open && "Utilisateurs"}</span></Link></li>
          <li className=''><Link to={"/"} className={`flex items-center gap-4 ${open?"px-3":"px-1 justify-center gap-1"} py-2 hover:bg-blue-100 font-medium hover:text-blue-600 transition`} ><School size={20}/><span>{open && "Ecoles"}</span></Link></li>
          <li className=''><Link to={"/"} className={`flex items-center gap-4 ${open?"px-3":"px-1 justify-center gap-1"} py-2 hover:bg-blue-100 font-medium hover:text-blue-600 transition`} ><GraduationCap size={20}/><span>{open && "Eléves"}</span></Link></li>
          <li className=''><Link to={"/"} className={`flex items-center gap-4 ${open?"px-3":"px-1 justify-center gap-1"} py-2 hover:bg-blue-100 font-medium hover:text-blue-600 transition`} ><ContactRound size={20}/><span>{open && "Parents"}</span></Link></li>
          <li className=''><Link to={"/"} className={`flex items-center gap-4 ${open?"px-3":"px-1 justify-center gap-1"} py-2 hover:bg-blue-100 font-medium hover:text-blue-600 transition`} ><MessageSquareMore size={20}/><span>{open && "Messages"}</span></Link></li>
        </ul>
      </div>
      <button onClick={handleClick} className={`absolute ${open ? "left-60":"left-10"} top-12 w-9 h-9 flex items-center justify-center rounded-full bg-blue-600 text-white transition-all duration-300`}>
            {
            open?
            <CircleChevronLeft size={20}/>:
            <CircleChevronRight size={20}/>
            }
          </button>
        {open && <Ads/>}
    </div>
  )
}

export default Sidebar
