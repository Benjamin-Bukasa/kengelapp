// backend/middlewares/isAdmin.js
const { PrismaClient } = require('../generated/prisma');
const prisma = new PrismaClient();

/**
 * Middleware pour vérifier si l'utilisateur est un administrateur.
 */
module.exports = async (req, res, next) => {
  try {
    const user = await prisma.t_Utilisateurs.findUnique({
      where: { IdUser: req.userId },
      select: { Is_Admin: true }
    });

    if (!user || !user.Is_Admin) {
      return res.status(403).json({ message: 'Accès réservé aux administrateurs' });
    }

    next();
  } catch (error) {
    return res.status(500).json({ message: 'Erreur interne de vérification des droits' });
  }
};
