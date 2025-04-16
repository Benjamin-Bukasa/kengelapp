const express = require('express');
const router = express.Router();
const CategorieGeneriqueController = require('../../controllers/dba/categorieGenerique.controller.dba');

router.get("/", CategorieGeneriqueController.getAll);       // GET all
router.get("/:id", CategorieGeneriqueController.getById);    // GET by ID
router.post("/", CategorieGeneriqueController.create);       // CREATE
router.put("/:id", CategorieGeneriqueController.update);     // UPDATE
router.delete("/:id", CategorieGeneriqueController.delete);  // DELETE

module.exports = router;
