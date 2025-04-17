const { DataTypes } = require('sequelize');
const sequelize = require('../../config/sequelize');
const Utilisateur = require('./utilisateurs.orm');
const Generique = require('./generique.orm');
const Entite = require('./entite.orm');

const Enseignant = sequelize.define('Enseignant', {
  IdEnseignant: {type: DataTypes.INTEGER,primaryKey: true,autoIncrement: true,field: 'IdEnseignant'},
  IdUserFk: {type: DataTypes.INTEGER,allowNull: true,field: 'IdUserFk'},
  IdSpecialiteEnseignantFk: {type: DataTypes.INTEGER,allowNull: true,field: 'IdSpecialiteEnseignantFk'},
  SalaireEnseignant: {type: DataTypes.INTEGER,allowNull: true,field: 'SalaireEnseignant',validate: {  min: 0}},
  DateEmbaucheEnseignant: {type: DataTypes.DATEONLY,allowNull: true,field: 'DateEmbaucheEnseignant'},
  ValideEnseignant: {type: DataTypes.BOOLEAN,defaultValue: true,allowNull: false,field: 'ValideEnseignant'},
  CodeEnseignant: {type: DataTypes.STRING(25),allowNull: true,field: 'CodeEnseignant'},
  IdDeviseFk: {type: DataTypes.INTEGER,allowNull: false,field: 'IdDeviseFk'},
  IdEntiteFk: {type: DataTypes.INTEGER,allowNull: true,field: 'IdEntiteFk'}
}, {
  tableName: 'T_Enseignant',
  timestamps: false,
  freezeTableName: true
});

// Associations (relations avec les autres modèles)
Enseignant.belongsTo(Utilisateur, {foreignKey: 'IdUserFk',onUpdate: 'CASCADE', onDelete: 'SET NULL'});
Enseignant.belongsTo(Generique, {foreignKey: 'IdDeviseFk',onUpdate: 'CASCADE',onDelete: 'SET NULL'});
Enseignant.belongsTo(Generique, {foreignKey: 'IdSpecialiteEnseignantFk',onUpdate: 'CASCADE',onDelete: 'SET NULL'});
Enseignant.belongsTo(Entite, {foreignKey: 'IdEntiteFk',onUpdate: 'CASCADE',onDelete: 'SET NULL'});

module.exports = Enseignant;
