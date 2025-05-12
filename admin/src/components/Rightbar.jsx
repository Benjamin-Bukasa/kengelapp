import { useOpen } from '../store/store'
import UserBadge from './Rightbar/UserBadge'
import UserOptions from './Rightbar/UserOptions'

const RightBar = () => {
  const { isOpen } = useOpen()

  return (
    <div className={`${isOpen ? "w-96 transition-all duration-300" : "w-16 hidden overflow-hidden transition duration-300"} p-1 flex flex-col min-h-screen border border-r-grey-200 transition-all duration-300`}>
      <div className="flex items-center justify-center font-poppins">
        {isOpen?<UserOptions/>:<div className='py-2 '><UserBadge/></div>}
      </div>
      <div className="">
      </div>
    </div>
  )
}

export default RightBar
