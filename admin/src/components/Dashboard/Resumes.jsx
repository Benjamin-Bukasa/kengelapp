import React from 'react'
import Resume from './Resume'
// import Sparkchart from './Sparkchart'
import { School,GraduationCap,Users,ShieldUser} from 'lucide-react'

const Resumes = () => {
  return (
    <div className='flex justify-between items-center gap-3 px-0 py-3'>
      <Resume resumeIcon={<School />} resumeText="Ecole" resumeValue={36} resumeComment="Augmentation"/>
      <Resume resumeIcon={<GraduationCap />} resumeText="Elèves" resumeValue={8208} resumeComment="Augmentation"/>
      <Resume resumeIcon={<Users />} resumeText="Utilisateurs" resumeValue={7943} resumeComment="Augmentation"/>
      <Resume resumeIcon={<ShieldUser />} resumeText="Parents" resumeValue={7896} resumeComment="Diminution"/>
    </div>
  )
}

export default Resumes
