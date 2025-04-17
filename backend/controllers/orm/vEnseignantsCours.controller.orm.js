const VEnseignantsCours = require('../../models/orm/vEnseignantsCours.orm');

const VEnseignantsCoursController = {
  getAll: async (req, res) => {
    try {
      const data = await VEnseignantsCours.findAll();
      res.status(200).json(data);
    } catch (error) {
      console.error('Erreur lors de la récupération de V_EnseignantsCours :', error);
      res.status(500).json({ error: 'Erreur serveur' });
    }
  }
};

module.exports = VEnseignantsCoursController;
