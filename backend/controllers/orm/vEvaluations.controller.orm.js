const VEvaluations = require('../../models/orm/vEvaluations.orm');

const VEvaluationsController = {
  getAll: async (req, res) => {
    try {
      const data = await VEvaluations.findAll();
      res.status(200).json(data);
    } catch (error) {
      console.error('Erreur lors de la récupération des évaluations :', error);
      res.status(500).json({ error: 'Erreur serveur' });
    }
  }
};

module.exports = VEvaluationsController;
