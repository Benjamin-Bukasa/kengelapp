const VEnseignantSalaire = require('../../models/orm/vEnseignantSalaire.orm');

const VEnseignantSalaireController = {
  getAll: async (req, res) => {
    try {
      const data = await VEnseignantSalaire.findAll();
      res.status(200).json(data);
    } catch (error) {
      console.error('Erreur lors de la récupération de V_EnseignantSalaire :', error);
      res.status(500).json({ error: 'Erreur serveur' });
    }
  }
};

module.exports = VEnseignantSalaireController;
