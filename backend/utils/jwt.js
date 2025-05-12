// backend/utils/jwt.js
const jwt = require('jsonwebtoken');

const MAX_AGE = parseInt(process.env.ACCESS_TOKEN_EXPIRE_MINUTES || '30') * 60; // en secondes
const REFRESH_AGE = parseInt(process.env.REFRESH_TOKEN_EXPIRE_DAYS || '7') * 24 * 60 * 60;

/**
 * Crée un token JWT signé.
 * @param {string} userId - L'identifiant utilisateur à signer.
 */
const createToken = (userId) => {
  return jwt.sign({ userId }, process.env.JWT_SECRET, {
    expiresIn: MAX_AGE,
  });
};

/**
 * Vérifie et décode un token JWT.
 * @param {string} token - Le token à vérifier.
 * @returns {object} - Le payload décodé.
 */
const verifyTokenJWT = (token) => {
  return jwt.verify(token, process.env.JWT_SECRET);
};

const createRefreshToken = (userId) => {
  return jwt.sign({ userId }, process.env.JWT_REFRESH_SECRET, {
    expiresIn: REFRESH_AGE,
  });
};

module.exports = { createToken, verifyTokenJWT, createRefreshToken };


