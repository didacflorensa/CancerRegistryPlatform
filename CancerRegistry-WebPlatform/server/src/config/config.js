const dbSettings = {
  db_dialect: process.env.DB_DIALECT || '',
  db_host: process.env.DB_HOST       || '',
  db_port: process.env.DB_PORT || '27017',
  db_name: process.env.DB_NAME || '',
  db_user: process.env.DB_USER || '',
  db_password: process.env.DB_PASSWORD   || ''
}

const serverSettings = {
  port: process.env.PORT || 3000,
  ssl: require('./ssl')
}

module.exports = Object.assign({}, { dbSettings, serverSettings })
