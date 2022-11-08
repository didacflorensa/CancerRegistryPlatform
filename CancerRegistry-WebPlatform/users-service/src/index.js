'use strict'
console.log('--- Users Service ---')

const server = require('./server/server')
const config = require('./config')

  server.start({
        port: config.serverSettings.port,
        ssl: config.serverSettings.ssl,
        ldap:config.ldapSettings
      }).then(app => {
      console.log(`Server started successfully, running on port: ${config.serverSettings.port}.`)
    })

