const VEntite = require('../../models/orm/vEntite.orm');

const VEntiteController = {
  getAll: async (req, res) => {
    try {
      const data = await VEntite.findAll();
      res.status(200).json(data);
    } catch (error) {
      console.error('Erreur lors de la récupération de V_Entite :', error);
      res.status(500).json({ error: 'Erreur serveur' });
    }
  }
};

module.exports = VEntiteController;
