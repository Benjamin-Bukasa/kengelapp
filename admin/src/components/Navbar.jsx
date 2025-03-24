import React from 'react'
import { Search, Bell, Settings, EllipsisVertical } from 'lucide-react'
import { useOpen } from '../store'

const Navbar = () => {

  const { toggleIsOpen } = useOpen()

  return (
    <div className='flex justify-end items-center gap-10 px-2 py-2 border-b border-b-zinc-300'>

      {/* block du formulaire de recherche */}
      <form action="" className='w-[50%] p-1 flex items-center gap-1 border border-zinc-400 rounded-full'>
        <input type="text" placeholder='Recherche...' className='w-full px-2 py-1 bg-transparent outline-none rounded-full'/>
        <button className='p-2 bg-zinc-200 text-zinc-600 rounded-full hover:bg-blue-600 hover:text-white transition-all duration-150'><Search size={20}/></button>
      </form>

      {/* block pour les boutons */}
      <div className="flex justify-end items-center gap-5 px-1 py-2">
        <button className='p-2 bg-zinc-200 text-zinc-600 rounded-full hover:bg-blue-600 hover:text-white transition-all duration-150'><Bell size={20}/></button>
        <button className='p-2 bg-zinc-200 text-zinc-600 rounded-full hover:bg-blue-600 hover:text-white transition-all duration-150'><Settings size={20}/></button>
      </div>

      {/* Bouton pour ouvrir/fermer le rightbar */}
      <button
        onClick={toggleIsOpen}
        className='p-2 bg-zinc-200 text-zinc-600 rounded-full hover:bg-blue-600 hover:text-white transition-all duration-150'
      >
        <EllipsisVertical size={20} />
      </button>
    </div>
  )
}

export default Navbar
