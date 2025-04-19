import React from 'react'
import Banner from '../components/Dashboard/Banner.jsx'
import Resumes from '../components/Dashboard/Resumes'
import DataCharts from '../components/Dashboard/DataCharts.jsx'


function Dashboard() {

  return (
    <div className='w-full p-4 flex flex-col gap-4 font-poppins'>
      <Banner/>
      <Resumes/>
      <DataCharts/>
    </div>
  )
}

export default Dashboard
