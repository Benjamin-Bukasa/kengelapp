// backend/routes/orm/communication.routes.orm.js

const express = require("express");
const router = express.Router();
const CommunicationController = require('../../controllers/orm/communication.controller.orm');

router.get("/", CommunicationController.getAll);       
router.get("/:id", CommunicationController.getById);   
router.post("/", CommunicationController.create);     
router.put("/:id", CommunicationController.update);     
router.delete("/:id", CommunicationController.delete); 

module.exports = router;