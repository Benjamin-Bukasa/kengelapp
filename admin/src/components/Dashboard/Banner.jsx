import React from 'react'
import logo from "../../images/logoKengelapp.png"


const Banner = () => {
  return (
    <div className="flex-1 flex justify-between items-center text-white bg-blue-500 rounded-lg border shadow-md">
          <div className="w-1/3 flex-1 flex-col gap-2 px-4 py-4">
            <p className="">Bon retour !</p>
            <h1 className='text-4xl font-semibold'>Benjamin KABEYA</h1>
            <div className="">
             <span>Voir toutes les mise à jour manquées</span>

            </div>
          </div>
          <div className="">
            <img src={""} alt=""  className='w-2/3' />
          </div>
      </div>
  )
}

export default Banner
