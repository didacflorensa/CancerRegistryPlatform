module.exports = (app, options) => {
  const { repo } = options


  app.post('/all_by_year', (req, res, next) => {
    repo.getAllByYearData(req.body).then(_all => {
      res.status(200).json(_all)
    }).catch(next)
  })

  app.post('/incidence_by_counties', (req, res, next) => {
    repo.getInicidenceByCounties(req.body).then(_all => {
      res.status(200).json(_all)
    }).catch(next)
  })


  app.post('/evolution', (req, res, next) => {
    repo.getEvolutonData(req.body).then(_all => {
      res.status(200).json(_all)
    }).catch(next)
  })

  app.post('/evolution/didac', (req, res, next) => {
    repo.getEvolutionDidac(req.body).then(_all => {
      res.status(200).json(_all)
    }).catch(next)
  })


  app.get('/provinces', (req, res, next) => {
    repo.getAllProvinces().then(_all => {
      res.status(200).json(_all)
    }).catch(next)
  })

  app.get('/year/min', (req, res, next) => {
    repo.getYear(1).then(_all => {
      res.status(200).json(_all)
    }).catch(next)
  })

  app.get('/year/max', (req, res, next) => {
    repo.getYear(-1).then(_all => {
      res.status(200).json(_all)
    }).catch(next)
  })

  app.get('/loc3', (req, res, next) => {
    repo.getLoc3().then(_all => {
      res.status(200).json(_all)
    }).catch(next)
  })

  app.get('/subsequents', (req, res, next) => {
    repo.getSubsequents().then(_all => {
      res.status(200).json(_all)
    }).catch(next)
  })

  app.get('/overweight', (req, res, next) => {
    repo.getOverweight().then(_all => {
      res.status(200).json(_all)
    }).catch(next)
  })

  app.get('/obesity', (req, res, next) => {
    repo.getObesity().then(_all => {
      res.status(200).json(_all)
    }).catch(next)
  })

  app.get('/alcoholism', (req, res, next) => {
    repo.getAlcoholism().then(_all => {
      res.status(200).json(_all)
    }).catch(next)
  })


  app.get('/smoking', (req, res, next) => {
    repo.getSmoking().then(_all => {
      res.status(200).json(_all)
    }).catch(next)
  })

  app.get('/diabetes', (req, res, next) => {
    repo.getDiabetes().then(_all => {
      res.status(200).json(_all)
    }).catch(next)
  })

  app.get('/cim10/show', (req, res, next) => {
    repo.getCim10List().then(_all => {
      res.status(200).json(_all)
    }).catch(next)
  })

  app.get('/cim10/show/didac', (req, res, next) => {
    repo.getCim10List().then(_all => {
      res.status(200).json(_all)
    }).catch(next)
  })

  app.get('/age/group/count/show/:sexe/:location/:any_inici/:any_fi', (req, res, next) => {
    repo.getAgeGroupsCountMortality(req).then(_all => {
      res.status(200).json(_all)
    }).catch(next)
  })

  app.get('/mortality/count/show/:sexe/:any_inici/:any_fi', (req, res, next) => {
    repo.getMortalityCasesBySex(req).then(_all => {
      res.status(200).json(_all)
    }).catch(next)
  })

  app.get('/mortality/evolution/:sexe/:location', (req, res, next) => {
    repo.getEvolutionByYear(req).then(_all => {
      res.status(200).json(_all)
    }).catch(next)
  })

  app.get('/all/:yearmin/:yearmax', (req, res, next) => {
    repo.getByYears(req).then(_all => {
      res.status(200).json(_all)
    }).catch(next)
  })

  app.get('/mortality/total/show/:year_min/:year_max', (req, res, next) => {
    repo.getMortalityCasesGroupBySex(req).then(_all => {
      res.status(200).json(_all)
    }).catch(next)
  })

  app.post('/cancer/cases/sex', (req, res, next) => {
    repo.getTotalCancerCasesBySex(req.body).then(_all => {
      res.status(200).json(_all)
    }).catch(next)
  })

  app.post('/cancer/cases/location', (req, res, next) => {
    repo.getCancerCasesByYearSex(req.body).then(_all => {
      res.status(200).json(_all)
    }).catch(next)
  })

  app.post('/cancer/age', (req, res, next) => {
    repo.getAvgAgeSex(req.body).then(_all => {
      res.status(200).json(_all)
    }).catch(next)
  })

  app.post('/cancer/age/groups', (req, res, next) => {
    repo.getAgeGroupsCount(req.body).then(_all => {
      res.status(200).json(_all)
    }).catch(next)
  })

  app.post('/cancer/cases/location/sex', (req, res, next) => {
    repo.getLocationCasesGroupBySex(req.body).then(_all => {
      res.status(200).json(_all)
    }).catch(next)
  })

  app.post('/cancer/incidence/regions', (req, res, next) => {
    repo.getIncidenceByRegion(req.body).then(_all => {
      res.status(200).json(_all)
    }).catch(next)
  })

}
