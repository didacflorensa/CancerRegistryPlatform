const mongoose = require('mongoose')

const connect = (options, mediator) => {
  mediator.once('boot.ready', () => {
    const db = options

    const MongoLocation = 'mongodb://' + db.db_user + ':' + db.db_password + '@' + db.db_host + ':' + db.db_port + '/' + db.db_name

    mongoose.connect(MongoLocation, { useNewUrlParser: true,
      useUnifiedTopology: true,
      useCreateIndex: true,
      useFindAndModify: false, keepAlive: 120 }).catch((err) => {
      console.log('*** Can Not Connect to Mongo Server:', mongo_location)
    })

    mongoose.set('useFindAndModify', false)

    mongoose.connection
            .once('open', () => {
              mediator.emit('db.ready', db)
            })
            .on('error', (error) => {
              console.warn('Error : ', error)
              mediator.emit('db.error', error)
            })
  })
}

module.exports = Object.assign({}, {connect})
