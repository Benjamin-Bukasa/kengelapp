// backend/middlewares/isstaff.js
const { PrismaClient } = require('../generated/prisma');
const prisma = new PrismaClient();

/**
 * Middleware pour vérifier si l'utilisateur est un staff.
 */
module.exports = async (req, res, next) => {
  try {
    const user = await prisma.t_Utilisateurs.findUnique({
      where: { IdUser: req.userId },
      select: { Is_staff: true }
    });

    if (!user || !user.Is_staff) {
      return res.status(403).json({ message: 'Accès réservé au personnel autorisé' });
    }

    next();
  } catch (error) {
    return res.status(500).json({ message: 'Erreur interne de vérification des droits' });
  }
};
