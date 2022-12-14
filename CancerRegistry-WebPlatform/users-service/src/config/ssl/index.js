const fs = require('fs')

module.exports = {
  key: fs.readFileSync(`${__dirname}/server.key`),
  cert: fs.readFileSync(`${__dirname}/server.crt`),
  ldapcert: fs.readFileSync(`${__dirname}/openldap/cacert.crt`)
}
