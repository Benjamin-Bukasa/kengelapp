import React from 'react'
import { ResumeBar } from './ResumeBar'
import { DonutChart } from './DonutChart'


const DataCharts = () => {
  return (
    <>
    <div className="flex-1 items-stretch flex gap-5">
      <div className="w-1/2 flex flex-col justify-stretch  gap-8">
      <ResumeBar/>
      </div>
      <div className="w-1/2 flex flex-col justify-stretch   items-stretch">
      {/* <ResumeBar/> */}
      <DonutChart/>
      </div>
    </div>
    </>
  )
}

export default DataCharts
