const mongoose = require('mongoose')

let Loc3Schema = new mongoose.Schema({
  'Code': { type: String },
  'Desc': { type: String }
}, { timestamps: false })

const Loc3 = mongoose.model('Loc3', Loc3Schema, 'loc3')
module.exports = { Loc3, Loc3Schema }