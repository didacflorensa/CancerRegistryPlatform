const mongoose = require('mongoose')

let  MortalitySchema = new mongoose.Schema({
  'number': {type: Number},
  'data_naix': {type: Date},
  'data_def': {type: Date},
  'CAUSA10': {type: String},
  'cim10_descr': {type: String},
  'age': {type: Number},
  'sexe': {type: Number},
  'sexe_descr': {type: String},
  'municipi': {type: Number},
  'comarca': {type: Number},
  'nom_comarca': {type: String},
  'ANYD': {type: Number},
  'age_group': {type: String},
}, {timestamps: false})

const Mortality = mongoose.model('Mortality', MortalitySchema, 'mortality')
module.exports = {Mortality, MortalitySchema}