const VEnseignant = require('../../models/orm/vEnseignant.orm');

const VEnseignantController = {
  getAll: async (req, res) => {
    try {
      const data = await VEnseignant.findAll();
      res.status(200).json(data);
    } catch (error) {
      console.error('Erreur lors de la récupération de V_Enseignant :', error);
      res.status(500).json({ error: 'Erreur serveur' });
    }
  }
};

module.exports = VEnseignantController;
