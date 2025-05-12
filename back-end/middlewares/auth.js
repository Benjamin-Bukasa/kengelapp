const jwt = require('jsonwebtoken');

module.exports = (req, res, next) => {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ message: 'Token manquant ou invalide' });
  }

  const token = authHeader.split(' ')[1];

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    console.log("Token décodé avec succès :", decoded); // ✅
    req.userId = decoded.userId;
    next();
  } catch (err) {
    console.error("Erreur de token :", err.message);
    res.status(403).json({ message: 'Token invalide ou expiré' });
  }
};
