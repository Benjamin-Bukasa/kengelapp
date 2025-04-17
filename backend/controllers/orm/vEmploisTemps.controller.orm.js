const VEmploisTemps = require('../../models/orm/vEmploisTemps.orm');

const VEmploisTempsController = {
  getAll: async (req, res) => {
    try {
      const data = await VEmploisTemps.findAll();
      res.status(200).json(data);
    } catch (error) {
      console.error('Erreur lors de la récupération de V_EmploisTemps :', error);
      res.status(500).json({ error: 'Erreur serveur' });
    }
  }
};

module.exports = VEmploisTempsController;
