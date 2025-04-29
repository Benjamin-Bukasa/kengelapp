// backend/routes/index.routes.js
const express = require('express');
const router = express.Router();
const crudController = require('../controllers/crud.controller');
const getPrismaModels = require('../utils/getPrismaModels');

const models = getPrismaModels(); // ['T_Apprenant', 'T_Entite', ...]

models.forEach((modelName) => {
  const path = `/${modelName.toLowerCase()}`;

  router.get(path, crudController.getAll(modelName));
  router.get(`${path}/:id`, crudController.getOne(modelName));
  router.post(path, crudController.create(modelName));
  router.put(`${path}/:id`, crudController.update(modelName));
  router.delete(`${path}/:id`, crudController.remove(modelName));
});

module.exports = router;
