const passport = require('passport');
const LdapStrategy = require('passport-ldapauth');

module.exports = (app, options) => {

  passport.use(new LdapStrategy(options.ldap));
  app.post('/login', function(req, res, next) {
    passport.authenticate('ldapauth', {session: false}, function(err, user, info) {
      if (err) {
        return next(err); 
      }
      if (! user) {
        return res.status(401).send({ success : false, message : 'unauthorized',code:401 });
      }
      return res.send({ success : true, message : 'ok' , code:200});
    })(req, res, next);
  });


}