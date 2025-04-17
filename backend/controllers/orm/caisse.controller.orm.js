const Caisse = require('../../models/orm/caisse.orm'); 

const CaisseController = {
  // Récupérer toutes les caisses
  getAll: async (req, res) => {
    try {
      const caisses = await Caisse.findAll();
      res.status(200).json(caisses);
    } catch (err) {
      res.status(500).json({ message: err.message });
    }
  },

  // Récupérer une caisse par son ID
  getById: async (req, res) => {
    try {
      const id = parseInt(req.params.id);
      const caisse = await Caisse.findByPk(id);
      if (!caisse) {
        return res.status(404).json({ message: "Caisse non trouvée" });
      }
      res.status(200).json(caisse);
    } catch (err) {
      res.status(500).json({ message: err.message });
    }
  },

  // Créer une nouvelle caisse
  create: async (req, res) => {
    try {
      const newCaisse = await Caisse.create(req.body);
      res.status(201).json(newCaisse);
    } catch (err) {
      res.status(400).json({ message: err.message });
    }
  },

  // Mettre à jour une caisse existante
  update: async (req, res) => {
    try {
      const id = parseInt(req.params.id);
      const existingCaisse = await Caisse.findByPk(id);
      if (!existingCaisse) {
        return res.status(404).json({ message: "Caisse non trouvée" });
      }
      await existingCaisse.update(req.body);
      res.status(200).json(existingCaisse);
    } catch (err) {
      res.status(400).json({ message: err.message });
    }
  },

  // Supprimer une caisse
  delete: async (req, res) => {
    try {
      const id = parseInt(req.params.id);
      const existingCaisse = await Caisse.findByPk(id);
      if (!existingCaisse) {
        return res.status(404).json({ message: "Caisse non trouvée" });
      }
      await existingCaisse.destroy();
      res.status(200).json({ message: "Caisse supprimée" });
    } catch (err) {
      res.status(500).json({ message: err.message });
    }
  }
};

module.exports = CaisseController;
