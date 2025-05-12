import React from 'react'
import Banner from '../components/Dashboard/Banner.jsx'
import Resumes from '../components/Dashboard/Resumes'
import DataCharts from '../components/Dashboard/DataCharts.jsx'
import AdvancedTable from '../components/AdvancedTable.jsx'


function Dashboard() {

  return (
    <div className='w-full p-4 flex flex-col gap-4 font-poppins'>
      <Banner/>
        <Resumes/>
      <div className="flex p-4 justify-between items-center">
        <DataCharts/>
      </div>
      <div className="p-4 border rounded-md shadow-sm">
        <AdvancedTable/>
      </div>
    </div>
  )
}

export default Dashboard
