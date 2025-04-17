const ActiviteParticipants = require('../../models/orm/activiteParticipants.orm');

const ActiviteParticipantsController = {
  getAll: async (req, res) => {
    try {
      const participants = await ActiviteParticipants.findAll();
      res.status(200).json(participants);
    } catch (error) {
      res.status(500).json({ message: error.message });
    }
  },

  getById: async (req, res) => {
    try {
      const participant = await ActiviteParticipants.findByPk(req.params.id);
      if (!participant) {
        return res.status(404).json({ message: 'Participant non trouvé' });
      }
      res.status(200).json(participant);
    } catch (error) {
      res.status(500).json({ message: error.message });
    }
  },

  create: async (req, res) => {
    try {
      const nouveauParticipant = await ActiviteParticipants.create(req.body);
      res.status(201).json(nouveauParticipant);
    } catch (error) {
      res.status(400).json({ message: error.message });
    }
  },

  update: async (req, res) => {
    try {
      const participant = await ActiviteParticipants.findByPk(req.params.id);
      if (!participant) {
        return res.status(404).json({ message: 'Participant non trouvé' });
      }
      await participant.update(req.body);
      res.status(200).json(participant);
    } catch (error) {
      res.status(400).json({ message: error.message });
    }
  },

  delete: async (req, res) => {
    try {
      const participant = await ActiviteParticipants.findByPk(req.params.id);
      if (!participant) {
        return res.status(404).json({ message: 'Participant non trouvé' });
      }
      await participant.destroy();
      res.status(200).json({ message: 'Participant supprimé' });
    } catch (error) {
      res.status(500).json({ message: error.message });
    }
  }
};

module.exports = ActiviteParticipantsController;
