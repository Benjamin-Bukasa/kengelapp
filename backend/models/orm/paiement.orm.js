// backend/models/orm/paiement.orm.js
const { DataTypes } = require('sequelize');
const sequelize = require('../../config/sequelize');
const Utilisateurs = require('./utilisateurs.orm');
const Generique = require('./generique.orm');
const Entite = require('./entite.orm');

const Paiement = sequelize.define('Paiement', {
  IdPaiement: {type: DataTypes.INTEGER,primaryKey: true,autoIncrement: true,field: 'IdPaiement'},
  CodePaiement: {type: DataTypes.STRING(25),allowNull: true,field: 'CodePaiement'},
  IdUserFk: {type: DataTypes.INTEGER,allowNull: false,field: 'IdUserFk'},
  IdTypePaiementFk: {type: DataTypes.INTEGER,allowNull: false,field: 'IdTypePaiementFk'},
  MontantPaiement: {type: DataTypes.DECIMAL(10, 2),allowNull: false,field: 'MontantPaiement'},
  IdStatutPaiementFk: {type: DataTypes.INTEGER,allowNull: true,field: 'IdStatutPaiementFk'},
  DatePaiement: {type: DataTypes.DATE,defaultValue: DataTypes.NOW,allowNull: false,field: 'DatePaiement'},
  ObsPaiement: {type: DataTypes.TEXT,allowNull: true,field: 'ObsPaiement'},
  ValidePaiement: {type: DataTypes.BOOLEAN,allowNull: false,defaultValue: true,field: 'ValidePaiement'},
  IdDeviseFk: {type: DataTypes.INTEGER,allowNull: false,field: 'IdDeviseFk'},
  IdPayeurFk: {type: DataTypes.INTEGER,allowNull: true,field: 'IdPayeurFk'},
  IdTypeMouvementFk: {type: DataTypes.INTEGER,allowNull: true,field: 'IdTypeMouvementFk'},
  IdEntiteFk: {type: DataTypes.INTEGER,allowNull: true,field: 'IdEntiteFk'}
}, 
{
  tableName: 'T_Paiement',
  timestamps: false
});

// Associations
Paiement.belongsTo(Utilisateurs, { foreignKey: 'IdUserFk', onUpdate: 'CASCADE', onDelete: 'SET NULL' });
Paiement.belongsTo(Generique, { foreignKey: 'IdTypePaiementFk', onUpdate: 'CASCADE', onDelete: 'SET NULL' });
Paiement.belongsTo(Generique, { foreignKey: 'IdStatutPaiementFk', onUpdate: 'CASCADE', onDelete: 'SET NULL' });
Paiement.belongsTo(Generique, { foreignKey: 'IdDeviseFk', onUpdate: 'CASCADE', onDelete: 'SET NULL' });
Paiement.belongsTo(Generique, { foreignKey: 'IdTypeMouvementFk', onUpdate: 'CASCADE', onDelete: 'SET NULL' });
Paiement.belongsTo(Entite, { foreignKey: 'IdEntiteFk', onUpdate: 'CASCADE', onDelete: 'CASCADE' });
Paiement.belongsTo(Utilisateurs, { foreignKey: 'IdPayeurFk', onUpdate: 'CASCADE', onDelete: 'SET NULL' });

module.exports = Paiement;
