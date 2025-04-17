const Salle = require('../../models/orm/salle.orm');  

const SalleController = {
  // Récupérer toutes les salles
  getAll: async (req, res) => {
    try {
      const salles = await Salle.findAll();
      res.status(200).json(salles);
    } catch (err) {
      res.status(500).json({ message: err.message });
    }
  },

  // Récupérer une salle par son ID
  getById: async (req, res) => {
    try {
      const id = parseInt(req.params.id);
      const salle = await Salle.findByPk(id);
      if (!salle) {
        return res.status(404).json({ message: "Salle non trouvée" });
      }
      res.status(200).json(salle);
    } catch (err) {
      res.status(500).json({ message: err.message });
    }
  },

  // Créer une nouvelle salle
  create: async (req, res) => {
    try {
      const newSalle = await Salle.create(req.body);
      res.status(201).json(newSalle);
    } catch (err) {
      res.status(400).json({ message: err.message });
    }
  },

  // Mettre à jour une salle existante
  update: async (req, res) => {
    try {
      const id = parseInt(req.params.id);
      const existingSalle = await Salle.findByPk(id);
      if (!existingSalle) {
        return res.status(404).json({ message: "Salle non trouvée" });
      }
      await existingSalle.update(req.body);
      res.status(200).json(existingSalle);
    } catch (err) {
      res.status(400).json({ message: err.message });
    }
  },

  // Supprimer une salle
  delete: async (req, res) => {
    try {
      const id = parseInt(req.params.id);
      const existingSalle = await Salle.findByPk(id);
      if (!existingSalle) {
        return res.status(404).json({ message: "Salle non trouvée" });
      }
      await existingSalle.destroy();
      res.status(200).json({ message: "Salle supprimée" });
    } catch (err) {
      res.status(500).json({ message: err.message });
    }
  }
};

module.exports = SalleController;
