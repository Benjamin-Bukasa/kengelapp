//backend/controllers/crud.controller.js
const prisma = require('../config/db');
const catchAsync = require('../middlewares/catchAsync');

const crudController = {
  getAll: (table) => catchAsync(async (req, res) => {
    const data = await prisma[table].findMany();
    res.json({ success: true, data });
  }),

  getOne: (table) => catchAsync(async (req, res) => {
    const { id } = req.params;
    const data = await prisma[table].findUnique({ where: { id: parseInt(id) } });
    res.json({ success: true, data });
  }),

  create: (table) => catchAsync(async (req, res) => {
    const newData = await prisma[table].create({ data: req.body });
    res.status(201).json({ success: true, data: newData });
  }),

  update: (table) => catchAsync(async (req, res) => {
    const { id } = req.params;
    const updatedData = await prisma[table].update({
      where: { id: parseInt(id) },
      data: req.body,
    });
    res.json({ success: true, data: updatedData });
  }),

  remove: (table) => catchAsync(async (req, res) => {
    const { id } = req.params;
    await prisma[table].delete({ where: { id: parseInt(id) } });
    res.json({ success: true, message: `${table} deleted successfully` });
  }),
};

module.exports = crudController;
