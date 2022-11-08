const serverSettings = {
  port: process.env.PORT || 3001,
  ssl: require('./ssl')
}

const ldapSettings = {
  server: {
    url: process.env.URL || 'ldaps://registre.cancer.udl.cat:636',
    bindDn: process.env.LDAPUSER || 'cn=admin,dc=registre,dc=cancer,dc=udl,dc=cat',
    bindCredentials: process.env.LDAPPASS || 'rC1nc2rLl34d1',
    searchBase: 'ou=users,dc=registre,dc=cancer,dc=udl,dc=cat',
    searchFilter: '(uid={{username}})',
    groupSearchBase: "ou=groups,dc=registre,dc=cancer,dc=udl,dc=cat",
    groupSearchFilter : '(memberUid={{username}})',
    groupSearchAttributes:'cn',
    tlsOptions: {
      ca: [
        serverSettings.ssl.ldapcert
      ]
    }
  }
}

module.exports = Object.assign({}, { ldapSettings, serverSettings })
