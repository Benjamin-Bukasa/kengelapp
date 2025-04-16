// backend/routes/orm/categorieGenerique.routes.orm.js

const express = require("express");
const router = express.Router();
const CategorieGeneriqueController = require('../../controllers/orm/categorieGenerique.controller.orm');

router.get("/", CategorieGeneriqueController.getAllCategories);       // GET all
router.get("/:id", CategorieGeneriqueController.getCategorieById);    // GET by ID
router.post("/", CategorieGeneriqueController.createCategorie);       // CREATE
router.put("/:id", CategorieGeneriqueController.updateCategorie);     // UPDATE
router.delete("/:id", CategorieGeneriqueController.deleteCategorie);  // DELETE

module.exports = router;