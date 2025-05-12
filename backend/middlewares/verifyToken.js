// backend/middlewares/verifyToken.js
const { verifyTokenJWT } = require('../utils/jwt');

/**
 * Middleware pour vérifier le token JWT dans l'en-tête Authorization.
 */
module.exports = (req, res, next) => {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ message: 'Token manquant ou invalide' });
  }

  const token = authHeader.split(' ')[1];

  try {
    const decoded = verifyTokenJWT(token); // Utilisation de la fonction centralisée
    req.userId = decoded.userId;
    next();
  } catch (err) {
    return res.status(403).json({ message: 'Token invalide ou expiré' });
  }
};

