const jwt = require("jsonwebtoken");

// Durée de validité (ex: 1 jour)
const MAX_AGE = 24 * 60 * 60; // en secondes

const createToken = (userId) => {
  return jwt.sign({ userId }, process.env.JWT_SECRET, {
    expiresIn: MAX_AGE
  });
};

module.exports = { createToken };
