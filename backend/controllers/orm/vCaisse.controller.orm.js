const VCaisse = require('../../models/orm/vCaisse.orm');

const VCaisseController = {
  getAll: async (req, res) => {
    try {
      const data = await VCaisse.findAll();
      res.status(200).json(data);
    } catch (error) {
      console.error('Erreur lors de la récupération de V_Caisse :', error);
      res.status(500).json({ error: 'Erreur serveur' });
    }
  }
};

module.exports = VCaisseController;
