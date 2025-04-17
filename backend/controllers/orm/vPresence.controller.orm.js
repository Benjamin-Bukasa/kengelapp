const VPresence = require('../../models/orm/vPresence.orm');

const VPresenceController = {
  getAll: async (req, res) => {
    try {
      const data = await VPresence.findAll();
      res.status(200).json(data);
    } catch (error) {
      console.error('Erreur lors de la récupération des présences :', error);
      res.status(500).json({ error: 'Erreur serveur' });
    }
  }
};

module.exports = VPresenceController;
