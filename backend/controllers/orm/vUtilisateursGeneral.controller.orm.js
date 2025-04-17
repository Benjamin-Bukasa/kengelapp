const VUtilisateursGeneral = require('../../models/orm/vUtilisateursGeneral.orm');

const VUtilisateursGeneralController = {
  getAll: async (req, res) => {
    try {
      const data = await VUtilisateursGeneral.findAll();
      res.status(200).json(data);
    } catch (error) {
      console.error('Erreur lors de la récupération des utilisateurs généraux :', error);
      res.status(500).json({ error: 'Erreur serveur' });
    }
  }
};

module.exports = VUtilisateursGeneralController;
