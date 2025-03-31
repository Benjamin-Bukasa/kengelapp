import React from 'react'
import { Link, useNavigate } from 'react-router-dom'
import logo from "../images/logoKengelapp.png"
import logoGoogle from "../images/logoGoogle.png"

const LoginForm = () => {

  const navigate = useNavigate()
  
const handleClick = () =>{
  navigate('/dashboard')
}

const handleSubmit = ()=>{

}


  return (
    <>
    <div className='flex justify-between items-center w-full overflow-hidden'>
      {/* block de gauche */}
      <div className="h-screen flex flex-col items-start justify-start gap-6 py-20">
      <div className="relative left-[-40px] w-48 h-20 bg-blue-200 rounded-xl rotate-[-25deg]"></div>
      <div className="relative left-[-40px] w-48 h-20 bg-orange-200 rounded-xl rotate-[-25deg]"></div>
      </div>

      {/* Block de formulaire */}
      <div className="flex flex-col justify-start items-between gap-4">

        {/* titre de la page */}
        <div className="flex flex-col items-center py-5 gap-5">
          <img src={logo} alt="" className="w-1/2" />
          <p className="font-semibold text-lg">Connectez-vous à votre compte</p>
        </div>
        <form onSubmit={handleSubmit} action="" className="w-full flex flex-col justify-start items-start gap-6 p-10 border shadow-md rounded-lg">
          <div className="w-full flex flex-col items-start justify-start gap-2">
            <span className="font-medium">Adresse email</span>
            <input type="email" className="w-full px-2 py-3 rounded-md border focus:border-blue-400 outline-none" />
          </div>

          <div className="w-full flex flex-col items-start justify-start gap-2">
            <span className="font-medium">Mot de passe</span>
            <input type="password" className="w-full px-2 py-3 rounded-md border focus:border-blue-400 outline-none" />
          </div>
          <div className="flex items-center justify-between gap-20">
            <p className="flex items-center justify-between gap-2.5">
              <input type="checkbox" className=''/>
              <span className=''>Se souvenir de moi</span>
            </p>
            <p className=""><Link to="">Mot de pass oublié?</Link></p>
          </div>
          <button className='w-full px-5 py-2.5 bg-orange-500 hover:bg-orange-600 ease-in-out delay-150 text-white text-center rounded-lg' onClick={handleClick}>Se connecter</button>
          <p className="w-full text-center text-gray-500">ou continuer avec</p>
          <button className="w-full flex items-center justify-center gap-4 border border-black px-5 py-2.5 font-semibold text-md text-center rounded-lg">
            <img src={logoGoogle} alt="" className="w-5" />
            <span>Mon compte Google</span>
            </button>
        </form>
        <p className="w-full text-center">
          <span>Je n'ai pas de compte </span>
          <Link to="">M'inscrire</Link>
        </p>
      </div>

      {/* block de droit */}
      <div className="h-screen py-20 flex flex-col items-start justify-end gap-6 ">
        <div className="relative right-[-40px] w-48 h-20 bg-blue-200 rounded-xl rotate-[25deg]"> </div>
        <div className="relative right-[-40px] w-48 h-20 bg-orange-200 rounded-xl rotate-[25deg]"> </div>
      </div>
    </div>
    </>
  )
}

export default LoginForm
