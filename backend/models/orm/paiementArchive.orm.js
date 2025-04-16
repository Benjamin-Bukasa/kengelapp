// backend/models/orm/paiementArchive.orm.js

const { DataTypes } = require('sequelize');
const sequelize = require('../../config/sequelize');
const Utilisateurs = require('./utilisateurs.orm');
const Generique = require('./generique.orm');
const Entite = require('./entite.orm');

const PaiementArchive = sequelize.define('PaiementArchive', {
  IdPaiement: {type: DataTypes.INTEGER,primaryKey: true,allowNull: false,field: 'IdPaiement'},
  CodePaiement: {type: DataTypes.STRING(25),allowNull: true,field: 'CodePaiement'},
  IdUserFk: {type: DataTypes.INTEGER,allowNull: true,field: 'IdUserFk'},
  IdTypePaiementFk: {type: DataTypes.INTEGER,allowNull: true,field: 'IdTypePaiementFk'},
  MontantPaiement: {type: DataTypes.DECIMAL(10, 2),allowNull: true,field: 'MontantPaiement'},
  IdStatutPaiementFk: {type: DataTypes.INTEGER,allowNull: true,field: 'IdStatutPaiementFk'},
  DatePaiement: {type: DataTypes.DATE,allowNull: true,field: 'DatePaiement'},
  ObsPaiement: {type: DataTypes.TEXT,allowNull: true,field: 'ObsPaiement'},
  ValidePaiement: {type: DataTypes.BOOLEAN,allowNull: true,defaultValue: true,field: 'ValidePaiement' },
  IdDeviseFk: {type: DataTypes.INTEGER,allowNull: true,field: 'IdDeviseFk' },
  IdPayeurFk: {type: DataTypes.INTEGER,allowNull: true,field: 'IdPayeurFk'},
  IdTypeMouvementFk: {type: DataTypes.INTEGER,allowNull: true,field: 'IdTypeMouvementFk'},
  DateArchivage: {type: DataTypes.DATE,defaultValue: DataTypes.NOW,allowNull: true,field: 'DateArchivage'},
  IdEntiteFk: {type: DataTypes.INTEGER,allowNull: true,field: 'IdEntiteFk'}
}, 
{
  tableName: 'T_Paiement_Archive',
  timestamps: false
});

// Associations
PaiementArchive.belongsTo(Utilisateurs, { foreignKey: 'IdUserFk', onUpdate: 'CASCADE', onDelete: 'SET NULL' });
PaiementArchive.belongsTo(Generique, { foreignKey: 'IdTypePaiementFk', onUpdate: 'CASCADE', onDelete: 'SET NULL' });
PaiementArchive.belongsTo(Generique, { foreignKey: 'IdStatutPaiementFk', onUpdate: 'CASCADE', onDelete: 'SET NULL' });
PaiementArchive.belongsTo(Generique, { foreignKey: 'IdDeviseFk', onUpdate: 'CASCADE', onDelete: 'SET NULL' });
PaiementArchive.belongsTo(Generique, { foreignKey: 'IdTypeMouvementFk', onUpdate: 'CASCADE', onDelete: 'SET NULL' });
PaiementArchive.belongsTo(Entite, { foreignKey: 'IdEntiteFk', onUpdate: 'CASCADE', onDelete: 'CASCADE' });
PaiementArchive.belongsTo(Utilisateurs, { foreignKey: 'IdPayeurFk', onUpdate: 'CASCADE', onDelete: 'SET NULL' });

module.exports = PaiementArchive;
