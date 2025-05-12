const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const axios = require('axios'); // ✅ ajouté ici
const { OAuth2Client } = require("google-auth-library");
const { PrismaClient } = require('../generated/prisma');
const prisma = new PrismaClient();
const { createToken } = require("../utils/jwt.js");

const client = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);

// login classique
const login = async (req, res) => {
  const { EmailUser, MotdepasseUser } = req.body;
  try {
    const user = await prisma.t_Utilisateurs.findUnique({ where: { EmailUser } });

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

// login via Google
const loginWithGoogle = async (req, res) => {
  const { token } = req.body;
  if (!token) {
    return res.status(400).json({ message: "Token manquant" });
  }

  try {
    const googleRes = await axios.get('https://www.googleapis.com/oauth2/v3/userinfo', {
      headers: {
        Authorization: `Bearer ${token}`
      }
    });

    const { email, given_name, family_name, picture } = googleRes.data;

    let user = await prisma.t_Utilisateurs.findUnique({ where: { EmailUser: email } });

    if (!user) {
      user = await prisma.t_Utilisateurs.create({
        data: {
          EmailUser: email,
          NomUser: family_name || "Nom",
          PrenomUser: given_name || "Prénom",
          SexeUser: "Non spécifié",
          MotdepasseUser: "GOOGLE_AUTH",
          ValideUser: true,
          ImageUser: picture || null
        }
      });
    }

    const jwtToken = jwt.sign({ userId: user.IdUser }, process.env.JWT_SECRET, { expiresIn: "1d" });

    res.status(200).json({
      token: jwtToken,
      user: {
        IdUser: user.IdUser,
        NomUser: user.NomUser,
        PrenomUser: user.PrenomUser,
        EmailUser: user.EmailUser,
        SexeUser: user.SexeUser,
        ValideUser: user.ValideUser,
        ImageUser: user.ImageUser
      }
    });
  } catch (err) {
    console.error("Erreur Google Auth :", err.response?.data || err.message);
    return res.status(401).json({ message: "Token Google invalide ou expiré" });
  }
};

// inscription
const register = async (req, res) => {
  const { NomUser, PrenomUser, EmailUser, MotdepasseUser, SexeUser } = req.body;

  try {
    if (!NomUser || !PrenomUser || !EmailUser || !MotdepasseUser || !SexeUser) {
      return res.status(400).json({ message: "Tous les champs sont obligatoires" });
    }

    // Vérifie si l'utilisateur existe déjà
    const existingUser = await prisma.t_Utilisateurs.findUnique({
      where: { EmailUser }
    });

    if (existingUser) {
      return res.status(409).json({ message: "Cet email est déjà utilisé" });
    }

    const hashedPassword = await bcrypt.hash(MotdepasseUser, 10);

    const newUser = await prisma.t_Utilisateurs.create({
      data: {
        NomUser,
        PrenomUser,
        SexeUser,
        EmailUser,
        MotdepasseUser: hashedPassword
      }
    });

    res.status(201).json({ message: "Utilisateur créé avec succès", user: newUser });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};


// utilisateur connecté
const currentUser = async (req, res) => {
  const userId = req.userId;
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
        ValideUser: true,
        ImageUser: true
      }
    });
    res.status(200).json(user);
  } catch (error) {
    res.status(400).json({ message: "Utilisateur introuvable" });
  }
};

module.exports = {
  login,
  register,
  currentUser,
  loginWithGoogle
};
