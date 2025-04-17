const { DataTypes } = require('sequelize');
const sequelize = require('../../config/sequelize');

const VEmploisTemps = sequelize.define('VEmploisTemps', {
  IdEmploisTemps: { type: DataTypes.INTEGER, primaryKey: true, field: 'IdEmploisTemps' },
  IdNomCoursFk: { type: DataTypes.INTEGER, field: 'IdNomCoursFk' },
  nom_cours: { type: DataTypes.STRING, field: 'nom_cours' },
  IdNiveauFk: { type: DataTypes.INTEGER, field: 'IdNiveauFk' },
  nom_niveau: { type: DataTypes.STRING, field: 'nom_niveau' },
  JourSemaine: { type: DataTypes.STRING, field: 'JourSemaine' },
  HeureDebut: { type: DataTypes.TIME, field: 'HeureDebut' },
  HeureFin: { type: DataTypes.TIME, field: 'HeureFin' },
  ObsEmploisTemps: { type: DataTypes.STRING, field: 'ObsEmploisTemps' },
  IdEntiteFk: { type: DataTypes.INTEGER, field: 'IdEntiteFk' },
  NomEntite: { type: DataTypes.STRING, field: 'NomEntite' },
  id_type_entite: { type: DataTypes.INTEGER, field: 'id_type_entite' },
  type_entite: { type: DataTypes.STRING, field: 'type_entite' }
}, {
  tableName: 'V_EmploisTemps',
  timestamps: false,
  freezeTableName: true
});

module.exports = VEmploisTemps;
