// backend/controllers/views.controller.js
// pour récupérer les vues
const prisma = require('../config/db');
const catchAsync = require('../middlewares/catchAsync');

const viewsController = {
  getView: (viewName) =>
    catchAsync(async (req, res) => {
      const result = await prisma.$queryRawUnsafe(`SELECT * FROM "${viewName}"`);
      res.json({ success: true, data: result });
    }),
};

module.exports = viewsController;

