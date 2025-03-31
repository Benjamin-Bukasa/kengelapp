import React from 'react'
import Banner from '../components/Dashboard/Banner.jsx'
import Resumes from '../components/Dashboard/Resumes'
import Datatable from '../components/Dashboard/Datatable'


function Dashboard() {

  return (
    <div className='w-full p-4 flex flex-col gap-4 font-poppins'>
      <Banner/>
      <Resumes/>
      <Datatable/>
    </div>
  )
}

export default Dashboard
