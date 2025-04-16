// backend/models/orm/cours.orm.js
const { DataTypes } = require('sequelize');
const sequelize = require('../../config/sequelize');
const Enseignant = require('./enseignant.orm');
const Entite = require('./entite.orm');
const Generique = require('./generique.orm');

const Cours = sequelize.define('Cours', {
  IdCours: {type: DataTypes.INTEGER,primaryKey: true,autoIncrement: true,field: 'IdCours'},
  DescriptionCours: {type: DataTypes.TEXT,field: 'DescriptionCours'},
  IdEnseignantFk: { type: DataTypes.INTEGER,allowNull: true,field: 'IdEnseignantFk'},
  ObsCours: {type: DataTypes.TEXT,field: 'ObsCours'},
  ValideCours: {type: DataTypes.BOOLEAN,allowNull: false,defaultValue: true,field: 'ValideCours'},
  PonderationCours: {type: DataTypes.INTEGER,field: 'PonderationCours'},
  PointMax: {type: DataTypes.INTEGER,allowNull: false,field: 'PointMax'},
  IdNiveauCoursFk: {type: DataTypes.INTEGER,allowNull: true,field: 'IdNiveauCoursFk'},
  IdNomCoursFk: {type: DataTypes.INTEGER,allowNull: true,field: 'IdNomCoursFk' },
  IdEntiteFk: {type: DataTypes.INTEGER,allowNull: true,field: 'IdEntiteFk'}
}, 
{
  tableName: 'T_Cours',
  timestamps: false
});

// Associations
Cours.belongsTo(Enseignant, { foreignKey: 'IdEnseignantFk', onUpdate: 'CASCADE', onDelete: 'SET NULL' });
Cours.belongsTo(Entite, { foreignKey: 'IdEntiteFk', onUpdate: 'CASCADE', onDelete: 'SET NULL' });
Cours.belongsTo(Generique, { foreignKey: 'IdNiveauCoursFk', onUpdate: 'CASCADE', onDelete: 'SET NULL' });
Cours.belongsTo(Generique, { foreignKey: 'IdNomCoursFk', onUpdate: 'CASCADE', onDelete: 'SET NULL' });

module.exports = Cours;
