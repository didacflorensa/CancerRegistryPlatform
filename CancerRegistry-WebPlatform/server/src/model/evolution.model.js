const mongoose = require('mongoose')

let EvolutionSchema = new mongoose.Schema({
    '_id': { type: String },
    'count': { type: Number },
    'poblacio': { type: Number }
}, { timestamps: false })

const Evolution = mongoose.model('Evolution', EvolutionSchema, 'tumors')
module.exports = { Evolution, EvolutionSchema }