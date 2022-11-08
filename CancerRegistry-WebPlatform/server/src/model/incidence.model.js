const mongoose = require('mongoose')

let IncidenceSchema = new mongoose.Schema({
  '_id': { type: String },
  'count': { type: Number },
  'poblacio': { type: Number }
}, { timestamps: false })

const Incidence = mongoose.model('Incidence', IncidenceSchema, 'patients')
module.exports = { Incidence, IncidenceSchema }