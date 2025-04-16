// backend/controllers/orm/categorieGenerique.controller.orm.js

const CategorieGenerique = require('../../models/orm/categorieGenerique.orm');

// GET all
exports.getAllCategories = async (req, res) => {
  try {
    const categories = await CategorieGenerique.findAll();
    res.status(200).json(categories);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// GET one by ID
exports.getCategorieById = async (req, res) => {
  try {
    const id = parseInt(req.params.id);
    const categorie = await CategorieGenerique.findByPk(id);

    if (!categorie) {
      return res.status(404).json({ message: "Catégorie non trouvée" });
    }

    res.status(200).json(categorie);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// POST create
exports.createCategorie = async (req, res) => {
  try {
    const nouvelleCategorie = await CategorieGenerique.create(req.body);
    res.status(201).json(nouvelleCategorie);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
};

// PUT update
exports.updateCategorie = async (req, res) => {
  try {
    const id = parseInt(req.params.id);
    const existing = await CategorieGenerique.findByPk(id);

    if (!existing) {
      return res.status(404).json({ message: "Catégorie non trouvée" });
    }

    await existing.update(req.body);
    res.status(200).json(existing);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
};

// DELETE
exports.deleteCategorie = async (req, res) => {
  try {
    const id = parseInt(req.params.id);
    const existing = await CategorieGenerique.findByPk(id);

    if (!existing) {
      return res.status(404).json({ message: "Catégorie non trouvée" });
    }

    await existing.destroy();
    res.status(200).json({ message: "Catégorie supprimée" });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};
