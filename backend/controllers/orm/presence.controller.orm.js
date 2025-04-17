const Presence = require('../../models/orm/presence.orm'); 

const PresenceController = {
  // Récupérer toutes les Presences
  getAll: async (req, res) => {
    try {
      const Presences = await Presence.findAll();
      res.status(200).json(Presences);
    } catch (err) {
      res.status(500).json({ message: err.message });
    }
  },

  // Récupérer une Presence par son ID
  getById: async (req, res) => {
    try {
      const id = parseInt(req.params.id);
      const Presence = await Presence.findByPk(id);
      if (!Presence) {
        return res.status(404).json({ message: "Presence non trouvée" });
      }
      res.status(200).json(Presence);
    } catch (err) {
      res.status(500).json({ message: err.message });
    }
  },

  // Créer une nouvelle Presence
  create: async (req, res) => {
    try {
      const newPresence = await Presence.create(req.body);
      res.status(201).json(newPresence);
    } catch (err) {
      res.status(400).json({ message: err.message });
    }
  },

  // Mettre à jour une Presence existante
  update: async (req, res) => {
    try {
      const id = parseInt(req.params.id);
      const existingPresence = await Presence.findByPk(id);
      if (!existingPresence) {
        return res.status(404).json({ message: "Presence non trouvée" });
      }
      await existingPresence.update(req.body);
      res.status(200).json(existingPresence);
    } catch (err) {
      res.status(400).json({ message: err.message });
    }
  },

  // Supprimer une Presence
  delete: async (req, res) => {
    try {
      const id = parseInt(req.params.id);
      const existingPresence = await Presence.findByPk(id);
      if (!existingPresence) {
        return res.status(404).json({ message: "Presence non trouvée" });
      }
      await existingPresence.destroy();
      res.status(200).json({ message: "Presence supprimée" });
    } catch (err) {
      res.status(500).json({ message: err.message });
    }
  }
};

module.exports = PresenceController;
