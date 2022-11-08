const mongoose = require('mongoose')

let  ProvincesSchema = new mongoose.Schema({
  'codi': {type: Number},
  'nom_catala': {type: String},
  'nom_oficial': {type: String},
  'codi_ccaa': {type: Number},
  'nom_ccaa': {type: String}
}, {timestamps: false})

const Provinces = mongoose.model('Provinces', ProvincesSchema, 'provincies')
module.exports = {Provinces, ProvincesSchema}