'use strict'
console.log('--- Registre de cancer ---')
console.log('Connecting to Registre de cancer repository...')

const repository = require('./repo/repository')
const server = require('./server/server')
const config = require('./config')

const {EventEmitter} = require('events')
const mediator = new EventEmitter()

mediator.on('db.ready', (db) => {
  let rep
  repository.connect(db)
    .then(repo => {
      console.log('Connected. Starting Server')
      rep = repo
      return server.start({
        port: config.serverSettings.port,
        ssl: config.serverSettings.ssl,
        repo
      })
    })
    .then(app => {
      console.log(`Server started succesfully, running on port: ${config.serverSettings.port}.`)
      app.on('close', () => {
        rep.disconnect()
      })
    })
})

mediator.on('db.error', (err) => {
  console.error(err)
})

config.db.connect(config.dbSettings, mediator)

mediator.emit('boot.ready')
