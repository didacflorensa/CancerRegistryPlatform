const mongoose = require('mongoose')

const patients = require('./patients.model')

let  TumorsSchema = new mongoose.Schema({
  'id_tumor': {type: Number},
  'data_inc_pobl': {type: Date},
  'ltum3': {type: String},
  'descr': {type: String},
  'categStatsLtum': {type: Number},
  'loc3': {type: String},
  'morf': {type: String},
  'metode_dx': {type: Number},
  'descrCA': {type: String},
  'lat': {type: String},
  'pt': {type: String},
  'pn': {type: String},
  'pm': {type: String},
  'estadi_p': {type: String},
  'id_pacient': {type: patients.PatientsSchema},
}, {timestamps: false})

const Tumors = mongoose.model('Tumors', TumorsSchema, 'tumors')
module.exports = {Tumors, TumorsSchema}