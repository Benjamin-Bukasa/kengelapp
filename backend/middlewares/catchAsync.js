//backend/middlewares/catchAsync.js
// Middleware pour gérer les erreurs asynchrones dans les contrôleurs
// Utilisé pour éviter de répéter le bloc try-catch dans chaque fonction asynchrone
module.exports = (fn) => (req, res, next) => {
    Promise.resolve(fn(req, res, next)).catch(next);
  };
  