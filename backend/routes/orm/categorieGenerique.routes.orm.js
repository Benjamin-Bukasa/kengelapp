// backend/routes/orm/categorieGenerique.routes.orm.js

const express = require("express");
const router = express.Router();
const CategorieGeneriqueController = require('../../controllers/orm/categorieGenerique.controller.orm');

router.get("/", CategorieGeneriqueController.getAll);       
router.get("/:id", CategorieGeneriqueController.getById);   
router.post("/", CategorieGeneriqueController.create);     
router.put("/:id", CategorieGeneriqueController.update);     
router.delete("/:id", CategorieGeneriqueController.delete); 

module.exports = router;