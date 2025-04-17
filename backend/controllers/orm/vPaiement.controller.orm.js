const VPaiement = require('../../models/orm/vPaiement.orm');

const VPaiementController = {
  getAll: async (req, res) => {
    try {
      const data = await VPaiement.findAll();
      res.status(200).json(data);
    } catch (error) {
      console.error('Erreur lors de la récupération des paiements :', error);
      res.status(500).json({ error: 'Erreur serveur' });
    }
  }
};

module.exports = VPaiementController;