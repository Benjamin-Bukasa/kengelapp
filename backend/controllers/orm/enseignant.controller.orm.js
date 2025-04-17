// backend/controllers/enseignant.controller.orm.js
const Enseignant = require('../../models/orm/enseignant.orm');

const EnseignantController = {
  // GET all
  getAll: async (req, res) => {
    try {
      const enseignants = await Enseignant.findAll();
      res.status(200).json(enseignants);
    } catch (err) {
      res.status(500).json({ message: err.message });
    }
  },

  // GET by ID
  getById: async (req, res) => {
    try {
      const id = parseInt(req.params.id);
      const enseignant = await Enseignant.findByPk(id);
      if (!enseignant) {
        return res.status(404).json({ message: "Enseignant non trouvé" });
      }
      res.status(200).json(enseignant);
    } catch (err) {
      res.status(500).json({ message: err.message });
    }
  },

  // POST
  create: async (req, res) => {
    try {
      const nouvelEnseignant = await Enseignant.create(req.body);
      res.status(201).json(nouvelEnseignant);
    } catch (err) {
      res.status(400).json({ message: err.message });
    }
  },

  // PUT
  update: async (req, res) => {
    try {
      const id = parseInt(req.params.id);
      const enseignant = await Enseignant.findByPk(id);
      if (!enseignant) {
        return res.status(404).json({ message: "Enseignant non trouvé" });
      }
      await enseignant.update(req.body);
      res.status(200).json(enseignant);
    } catch (err) {
      res.status(400).json({ message: err.message });
    }
  },

  // DELETE
  delete: async (req, res) => {
    try {
      const id = parseInt(req.params.id);
      const enseignant = await Enseignant.findByPk(id);
      if (!enseignant) {
        return res.status(404).json({ message: "Enseignant non trouvé" });
      }
      await enseignant.destroy();
      res.status(200).json({ message: "Enseignant supprimé" });
    } catch (err) {
      res.status(500).json({ message: err.message });
    }
  }
};

module.exports = EnseignantController;
