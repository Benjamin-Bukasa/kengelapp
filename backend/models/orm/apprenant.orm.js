// backend/models/orm/apprenant.orm.js
const { DataTypes } = require('sequelize');
const sequelize = require('../../config/sequelize');
const Entite = require('./entite.orm');
const Utilisateurs = require('./utilisateurs.orm');
const Generique = require('./generique.orm');

const Apprenant = sequelize.define('Apprenant', {
  IdApprenant: {type: DataTypes.INTEGER,primaryKey: true, autoIncrement: true,field: 'IdApprenant' },
  CodeApprenant: {type: DataTypes.STRING(25),field: 'CodeApprenant'},
  DateNaissanceApprenant: {type: DataTypes.DATEONLY, field: 'DateNaissanceApprenant' },
  IdParentApprenantFk: {type: DataTypes.INTEGER,field: 'IdParentApprenantFk'},
  IdUserFk: {type: DataTypes.INTEGER,field: 'IdUserFk',unique: true},
  ValideApprenant: {type: DataTypes.BOOLEAN,allowNull: false,defaultValue: true,field: 'ValideApprenant'},
  AgeApprenant: {type: DataTypes.INTEGER,field: 'AgeApprenant'},
  IdNiveauApprenantFk: {type: DataTypes.INTEGER,field: 'IdNiveauApprenantFk'},
  IdEntiteFk: {type: DataTypes.INTEGER,allowNull: false,field: 'IdEntiteFk'}
}, {
  tableName: 'T_Apprenant',
  timestamps: false,
  freezeTableName: true,
});

// Associations
Apprenant.belongsTo(Entite, { foreignKey: 'IdEntiteFk', onUpdate: 'CASCADE', onDelete: 'SET NULL' });
Apprenant.belongsTo(Utilisateurs, { foreignKey: 'IdParentApprenantFk', onUpdate: 'CASCADE', onDelete: 'SET NULL' });
Apprenant.belongsTo(Utilisateurs, { foreignKey: 'IdUserFk', onUpdate: 'CASCADE', onDelete: 'SET NULL' });
Apprenant.belongsTo(Generique, { foreignKey: 'IdNiveauApprenantFk', onUpdate: 'CASCADE', onDelete: 'SET NULL' });

module.exports = Apprenant;

