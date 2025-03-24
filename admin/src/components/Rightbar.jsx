import { useOpen } from '../store'

const RightBar = () => {
  const { isOpen } = useOpen()

  return (
    <div className={`${isOpen ? "w-96 transition-all duration-300" : "w-16 overflow-hidden transition duration-300"} flex flex-col min-h-screen border border-r-grey-200 transition-all duration-300`}>
      <div className="px-4 py-5">
        {isOpen?"Rightbar":"R"}
      </div>
      <div className="">
      </div>
    </div>
  )
}

export default RightBar
