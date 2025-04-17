const Evaluations = require('../../models/orm/evaluations.orm'); 

const EvaluationsController = {
  // Récupérer toutes les Evaluationss
  getAll: async (req, res) => {
    try {
      const Evaluationss = await Evaluations.findAll();
      res.status(200).json(Evaluationss);
    } catch (err) {
      res.status(500).json({ message: err.message });
    }
  },

  // Récupérer une Evaluations par son ID
  getById: async (req, res) => {
    try {
      const id = parseInt(req.params.id);
      const Evaluations = await Evaluations.findByPk(id);
      if (!Evaluations) {
        return res.status(404).json({ message: "Evaluations non trouvée" });
      }
      res.status(200).json(Evaluations);
    } catch (err) {
      res.status(500).json({ message: err.message });
    }
  },

  // Créer une nouvelle Evaluations
  create: async (req, res) => {
    try {
      const newEvaluations = await Evaluations.create(req.body);
      res.status(201).json(newEvaluations);
    } catch (err) {
      res.status(400).json({ message: err.message });
    }
  },

  // Mettre à jour une Evaluations existante
  update: async (req, res) => {
    try {
      const id = parseInt(req.params.id);
      const existingEvaluations = await Evaluations.findByPk(id);
      if (!existingEvaluations) {
        return res.status(404).json({ message: "Evaluations non trouvée" });
      }
      await existingEvaluations.update(req.body);
      res.status(200).json(existingEvaluations);
    } catch (err) {
      res.status(400).json({ message: err.message });
    }
  },

  // Supprimer une Evaluations
  delete: async (req, res) => {
    try {
      const id = parseInt(req.params.id);
      const existingEvaluations = await Evaluations.findByPk(id);
      if (!existingEvaluations) {
        return res.status(404).json({ message: "Evaluations non trouvée" });
      }
      await existingEvaluations.destroy();
      res.status(200).json({ message: "Evaluations supprimée" });
    } catch (err) {
      res.status(500).json({ message: err.message });
    }
  }
};

module.exports = EvaluationsController;
