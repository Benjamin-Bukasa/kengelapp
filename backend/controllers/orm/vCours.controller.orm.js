const VCours = require('../../models/orm/vCours.orm');

const VCoursController = {
  getAll: async (req, res) => {
    try {
      const data = await VCours.findAll();
      res.status(200).json(data);
    } catch (error) {
      console.error('Erreur lors de la récupération de V_Cours :', error);
      res.status(500).json({ error: 'Erreur serveur' });
    }
  }
};

module.exports = VCoursController;
