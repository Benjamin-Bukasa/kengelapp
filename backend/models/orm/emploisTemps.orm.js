// backend/models/orm/emploisTemps.orm.js
const { DataTypes } = require('sequelize');
const sequelize = require('../../config/sequelize');
const Generique = require('./generique.orm');
const Entite = require('./entite.orm');

const EmploisTemps = sequelize.define('EmploisTemps', {
  IdEmploisTemps: {type: DataTypes.INTEGER,primaryKey: true,autoIncrement: true,field: 'IdEmploisTemps'},
  IdNomCoursFk: {type: DataTypes.INTEGER,allowNull: true,field: 'IdNomCoursFk'},
  JourSemaine: {type: DataTypes.STRING,field: 'JourSemaine'},
  HeureDebut: {type: DataTypes.TIME,field: 'HeureDebut'},
  HeureFin: {type: DataTypes.TIME,field: 'HeureFin'},
  ObsEmploisTemps: {type: DataTypes.TEXT,field: 'ObsEmploisTemps'},
  ValideEmploisTemps: {type: DataTypes.BOOLEAN,defaultValue: true,field: 'ValideEmploisTemps'},
  IdNiveauFk: {type: DataTypes.INTEGER,allowNull: true,field: 'IdNiveauFk'},
  IdEntiteFk: {type: DataTypes.INTEGER,allowNull: true,field: 'IdEntiteFk'}
}, 
{
  tableName: 'T_EmploisTemps',
  timestamps: false,
  validate: {checkHeureDebutFin() {
    if (this.HeureDebut >= this.HeureFin) {
        throw new Error('HeureDebut doit être avant HeureFin');
    }}
  }
});

// Associations
EmploisTemps.belongsTo(Generique, { foreignKey: 'IdNiveauFk', onUpdate: 'CASCADE', onDelete: 'SET NULL' });
EmploisTemps.belongsTo(Generique, { foreignKey: 'IdNomCoursFk', onUpdate: 'CASCADE', onDelete: 'SET NULL' });
EmploisTemps.belongsTo(Entite, { foreignKey: 'IdEntiteFk', onUpdate: 'CASCADE', onDelete: 'SET NULL' });

module.exports = EmploisTemps;
