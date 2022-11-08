const mongoose = require('mongoose')

let  PatientsSchema = new mongoose.Schema({
  'id_pacient': {type: Number},
  'sexe': {type: Number},
  'data_naix': {type: Date},
  'codi_postal': {type: Number},
  'desc_postal': {type: String},
  'codi_poblacio': {type: Number},
  'exitus': {type: Number},
  'data_def': {type: Date},
  'data_def_rca': {type: Date},
  'data_def_hospitalaria': {type: Date}

}, {timestamps: false})

const Patients = mongoose.model('Patients', PatientsSchema, 'patients')
module.exports = {Patients, PatientsSchema}