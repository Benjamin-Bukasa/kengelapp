const Login = require('../../models/orm/login.orm');

const LoginController = {
  // Récupérer tous les login
  getAll: async (req, res) => {
    try {
      const logins = await Login.findAll();
      res.status(200).json(logins);
    } catch (err) {
      res.status(500).json({ message: err.message });
    }
  },

  // Récupérer un login par son Id
  getById: async (req, res) => {
    try {
      const id = parseInt(req.params.id);
      const login = await Login.findByPk(id);
      if (!login) {
        return res.status(404).json({ message: "Login non trouvé" });
      }
      res.status(200).json(login);
    } catch (err) {
      res.status(500).json({ message: err.message });
    }
  },

  // Créer un nouveau login
  create: async (req, res) => {
    try {
      const newLogin = await Login.create(req.body);
      res.status(201).json(newLogin);
    } catch (err) {
      res.status(400).json({ message: err.message });
    }
  },

  // Mettre à jour un login existant
  update: async (req, res) => {
    try {
      const id = parseInt(req.params.id);
      const existingLogin = await Login.findByPk(id);
      if (!existingLogin) {
        return res.status(404).json({ message: "Login non trouvé" });
      }
      await existingLogin.update(req.body);
      res.status(200).json(existingLogin);
    } catch (err) {
      res.status(400).json({ message: err.message });
    }
  },

  // Supprimer un login
  delete: async (req, res) => {
    try {
      const id = parseInt(req.params.id);
      const existingLogin = await Login.findByPk(id);
      if (!existingLogin) {
        return res.status(404).json({ message: "Login non trouvé" });
      }
      await existingLogin.destroy();
      res.status(200).json({ message: "Login supprimé" });
    } catch (err) {
      res.status(500).json({ message: err.message });
    }
  }
};

module.exports = LoginController;
