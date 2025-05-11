// backend/controllers/crud.controller.js

const prisma = require('../config/db');
const catchAsync = require('../middlewares/catchAsync');
const primaryKeys = require('../utils/primaryKeys');

// 🔧 Normalise le nom du modèle (ex: t_apprenant => T_Apprenant)
const normalizeModelName = (model) =>
  model.charAt(0).toUpperCase() + model.slice(1);

// 🔧 Vérifie que le modèle existe dans Prisma
const assertModelExists = (modelName) => {
  if (!prisma[modelName]) {
    throw new Error(`Modèle "${modelName}" introuvable dans Prisma.`);
  }
};

// 🔧 Récupère la clé primaire d’un modèle Prisma (clé simple uniquement ici)
const getPrimaryKey = (model) => {
  const modelName = normalizeModelName(model);
  const key = primaryKeys[modelName];
  if (!key) {
    const knownModels = Object.keys(primaryKeys).join(', ');
    throw new Error(
      `Clé primaire introuvable pour le modèle "${modelName}". Modèles connus : ${knownModels}`
    );
  }
  return key;
};

// 📥 CREATE
const create = (model) => catchAsync(async (req, res) => {
  const modelName = normalizeModelName(model);
  assertModelExists(modelName);

  const data = await prisma[modelName].create({ data: req.body });
  res.status(201).json({ success: true, data });
});

// 📤 READ ALL
const getAll = (model) => catchAsync(async (req, res) => {
  const modelName = normalizeModelName(model);
  assertModelExists(modelName);

  const data = await prisma[modelName].findMany();
  res.json({ success: true, data });
});

// 📤 READ ONE
const getOne = (model) => catchAsync(async (req, res) => {
  const modelName = normalizeModelName(model);
  assertModelExists(modelName);

  const primaryKey = getPrimaryKey(model);
  const id = req.params.id;
  const identifier = isNaN(id) ? id : Number(id);

  const data = await prisma[modelName].findUnique({
    where: {
      [primaryKey]: identifier,
    },
  });

  if (!data) {
    return res.status(404).json({
      success: false,
      message: 'Enregistrement introuvable.',
    });
  }

  res.json({ success: true, data });
});

// ✏️ UPDATE
const update = (model) => catchAsync(async (req, res) => {
  const modelName = normalizeModelName(model);
  assertModelExists(modelName);

  const primaryKey = getPrimaryKey(model);
  const id = req.params.id;
  const identifier = isNaN(id) ? id : Number(id);

  const data = await prisma[modelName].update({
    where: {
      [primaryKey]: identifier,
    },
    data: req.body,
  });

  res.json({ success: true, data });
});

// ❌ DELETE
const remove = (model) => catchAsync(async (req, res) => {
  const modelName = normalizeModelName(model);
  assertModelExists(modelName);

  const primaryKey = getPrimaryKey(model);
  const id = req.params.id;
  const identifier = isNaN(id) ? id : Number(id);

  const data = await prisma[modelName].delete({
    where: {
      [primaryKey]: identifier,
    },
  });

  res.json({ success: true, data });
});

module.exports = {
  getAll,
  getOne,
  create,
  update,
  remove,
};
