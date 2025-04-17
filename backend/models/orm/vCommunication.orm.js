const { DataTypes } = require('sequelize');
const sequelize = require('../../config/sequelize');

const VCommunication = sequelize.define('VCommunication', {
  IdCommunication: { type: DataTypes.INTEGER, field: 'IdCommunication', primaryKey: true },
  IdUserFk: { type: DataTypes.INTEGER, field: 'IdUserFk' },
  nom_utilisateur: { type: DataTypes.STRING, field: 'nom_utilisateur' },
  IdTypeCommunication: { type: DataTypes.INTEGER, field: 'IdTypeCommunication' },
  type_comm: { type: DataTypes.STRING, field: 'type_comm' },
  ContenuCommunication: { type: DataTypes.TEXT, field: 'ContenuCommunication' },
  DateCommunication: { type: DataTypes.DATE, field: 'DateCommunication' },
  ObsCommunication: { type: DataTypes.STRING, field: 'ObsCommunication' },
  ValideCommunication: { type: DataTypes.BOOLEAN, field: 'ValideCommunication' },
  LectureCommunication: { type: DataTypes.BOOLEAN, field: 'LectureCommunication' },
  IdEntiteFk: { type: DataTypes.INTEGER, field: 'IdEntiteFk' },
  NomEntite: { type: DataTypes.STRING, field: 'NomEntite' },
  id_type_entite: { type: DataTypes.INTEGER, field: 'id_type_entite' },
  type_entite: { type: DataTypes.STRING, field: 'type_entite' }
}, {
  tableName: 'V_Communication',
  timestamps: false,
  freezeTableName: true
});

module.exports = VCommunication;
