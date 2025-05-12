const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const {PrismaClient} = require('../generated/prisma');
const prisma = new PrismaClient();
const {createToken} = require("../utils/jwt.js");


// Function to get all users
const getAllUsers = async (req,res)=>{
    try {
        const users = await prisma.t_Utilisateurs.findMany();
        res.status(200).json(users);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
}


// Function to get a user by ID
const getUserById = async (req,res)=>{
    const { id } = req.params;
    try {
        const user = await prisma.t_Utilisateurs.findUnique({
            where: { IdUser: parseInt(id) }
        });
        if (!user) {
            return res.status(404).json({ message: "Utilisateur non trouvé" });
        }
        res.status(200).json(user);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
}

module.exports = {
    getAllUsers,
    getUserById
}

