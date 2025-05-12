const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const {PrismaClient} = require('../generated/prisma');
const prisma = new PrismaClient();
const {createToken} = require('../utils/jwt');
// Function to login a user

const login = async (req, res) => {
    const { EmailUser, MotdepasseUser } = req.body;
  
    try {
      const user = await prisma.t_Utilisateurs.findUnique({
        where: { EmailUser }
      });
  
      if (!user) {
        return res.status(404).json({ message: "Adresse email ou mot de passe incorrect" });
      }
  
      const isValid = await bcrypt.compare(MotdepasseUser, user.MotdepasseUser);
      if (!isValid) {
        return res.status(401).json({ message: "Mot de passe incorrect" });
      }
  
      const token = createToken(user.IdUser); 
      res.status(200).json({
        token,
        user: {
          id: user.IdUser,
          nom: user.NomUser,
          prenom: user.PrenomUser,
          email: user.EmailUser
        }
      });
    } catch (err) {
      res.status(500).json({ message: err.message });
    }
  };
  

  // Function to register a new user
const register = async (req, res) => {
    const { NomUser, PrenomUser, EmailUser, MotdepasseUser, SexeUser } = req.body
  
    try {

        if (!NomUser || !PrenomUser || !EmailUser || !MotdepasseUser || !SexeUser) {
            return res.status(400).json({ message: "Tous les champs sont obligatoires" })
        }

        const hashedPassword = await bcrypt.hash(MotdepasseUser, 10)
  
      const newUser = await prisma.t_Utilisateurs.create({
        data: {
          NomUser,
          PrenomUser,
          SexeUser,
          EmailUser,
          MotdepasseUser: hashedPassword
        }
      })
  
      res.status(201).json({ message: "Utilisateur créé avec succès", user: newUser })
    } catch (err) {
      res.status(500).json({ message: err.message })
    }
  }


// get the current user
const currentUser = async (req, res) => {
    const userId = req.userId
    try {
      const user = await prisma.t_Utilisateurs.findUnique({
        where: { IdUser: userId },
        select: {
          IdUser: true,
          NomUser: true,
          PrenomUser: true,
          EmailUser: true,
          SexeUser: true,
          Is_Admin: true,
          Is_staff: true,
          IdRoleFk: true,
          ValideUser: true
        }
      })
      res.status(200).json(user)
    } catch (error) {
      res.status(400).json({ message: "Utilisateur introuvable" })
    }
  }


// Export the functions
module.exports = { login, register, currentUser }