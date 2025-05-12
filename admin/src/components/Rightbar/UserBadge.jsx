import React from 'react'
import useAuthStore from '../../store/authStore'

const UserBadge = () => {

  const { user } = useAuthStore()
  const userFirstname = user ? user.PrenomUser : 'Utilisateur'
  const userLastname = user ? user.NomUser : 'Utilisateur'

  return (
    <div className="w-10 h-10 rounded-full flex flex-col justify-center bg-blue-600 text-white text-center">
                {userFirstname.charAt(0).toUpperCase()}
                {userLastname.charAt(0).toUpperCase()}
    </div>
  )
}

export default UserBadge
