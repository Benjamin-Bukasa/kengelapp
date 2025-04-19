import React from 'react'

const Resume = ({resumeIcon, resumeText, resumeValue, resumeComment}) => {
  return (
    <div className='flex justify-start items-start gap-5 w-1/4 p-2.5 rounded-lg shadow-sm border'>
      <div className="flex justify-center items-center rounded-full p-2 bg-zinc-200 text-zinc-600">
            {resumeIcon}
      </div>
      <div className="flex flex-col gap-1">
        <p className="text-md font-medium text-zinc-600">Total {resumeText}</p>
        <p className="font-medium text-zinc-800 text-2xl">{resumeValue}</p>
        <p className={`${resumeComment == "Augmentation"?"bg-green-100 text-green-600":"bg-red-100 text-red-600"} font-medium text-[10px] text-center px-3 py-0.5 rounded-md`}>{resumeComment}</p>
      </div>
    </div>
  ) 
}

export default Resume
