const VCommunication = require('../../models/orm/vCommunication.orm');

const VCommunicationController = {
  getAll: async (req, res) => {
    try {
      const data = await VCommunication.findAll();
      res.status(200).json(data);
    } catch (error) {
      console.error('Erreur lors de la récupération de V_Communication :', error);
      res.status(500).json({ error: 'Erreur serveur' });
    }
  }
};

module.exports = VCommunicationController;
