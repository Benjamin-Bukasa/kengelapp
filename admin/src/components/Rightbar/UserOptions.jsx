import React from 'react'
import { EllipsisVertical } from 'lucide-react'
import UserBadge from './UserBadge'
import useAuthStore from '../../store/authStore'

const UserOptions = () => {
  const { user } = useAuthStore()
  const userFirstname = user ? user.PrenomUser : 'Utilisateur'
  const userLastname = user ? user.NomUser : 'Utilisateur'
  const userRole = user ? user.RoleUser : 'Utilisateur'
  return (
    <div className='flex justify-between items-center w-full py-2.5 px-4 bg-white shadow-md border rounded-lg'>
      <div className="flex gap-5 ">
        <div className="w-10 h-10 rounded-full flex flex-col justify-center bg-blue-600 text-white text-center">
                <UserBadge/>
        </div>
        <div className="flex flex-col gap-0">
            <p className="font-semibold text-md">
                {userFirstname} {userLastname}
            </p>
            <p className="font-semibold text-gray-500">
                {userRole? userRole : 'Utilisateur'}
            </p>
        </div>
    </div>
      <button className='p-2 text-zinc-600 rounded-full hover:bg-zinc-600 hover:text-white transition-all duration-150'><EllipsisVertical size={20} /></button>
    </div>
  )
}

export default UserOptions
