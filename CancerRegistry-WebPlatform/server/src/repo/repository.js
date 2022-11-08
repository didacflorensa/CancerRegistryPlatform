'use strict'

const repository = (db) => {

  const patients_db = require('../model/patients.model')
  const tumors_db = require('../model/tumors.model')
  const provinces_db = require('../model/provinces.model')
  const loc3_db = require('../model/loc3.model')
  const incidence_db = require('../model/incidence.model')
  const evolution_db = require('../model/evolution.model')
  const mortality_db = require('../model/mortality.model')





  const getYear = (order) => {
    return new Promise((resolve, reject) => {
      tumors_db.Tumors.aggregate(
          [
            {
              $addFields: {
                data_inc_pobl: { $toDate: "$data_inc_pobl" }
              }
            },
            {
              $sort: {
                data_inc_pobl: order // 1 -> Min, -1 -> Max
              }
            }, {
            $limit: 1
          }, {
            $project: {
              year: { $year: "$data_inc_pobl" },
            }
          }]
      ).then(_matrix => {
        resolve(_matrix)
      })
    })
  }


  const getAllProvinces = () => {
    return new Promise((resolve, reject) => {
      provinces_db.Provinces.find().then(_matrix => {
        resolve(_matrix)
      })
    })
  }

  const getLoc3 = () => {
    return new Promise((resolve, reject) => {
      loc3_db.Loc3.find().then(_matrix => {
        resolve(_matrix)
      })
    })
  }



  const getAllByYearData = (options) => {

    console.log(options)

    var aggregation_filter = [
      { $match: { "morf": { "$ne": "M-80903" } } },
      { $match: { "morf": { "$ne": "M-80913" } } },
      { $match: { "morf": { "$ne": "M-80923" } } },
      { $match: { "morf": { "$ne": "M-80973" } } },
      { $match: { "morf": { "$ne": "M-80933" } } },
      { $match: { "morf": { "$ne": "M-80943" } } },
      { $match: { "morf": { "$ne": "M-80953" } } },
      { $match: { "morf": { "$ne": "M-80983" } } },
      {
        $match: {
          "data_inc_pobl": {
            "$gte": new Date(options.year_min, 1, 1),
            "$lt": new Date(options.year_max + 1, 1, 1)
          }
        }
      }

    ]



    if (options.loc3) {
      aggregation_filter.push(
          {
            '$match': {
              'loc3': options.loc3
            }
          })
    }



    //if (selected_population == "Poblacional") {
    //  aux < - aux[aux["patient.codi_postal"] > 25000 & aux["patient.codi_postal"] < 25999, ]
    //} else if (selected_population == "Hospitalari") {
    //  aux < - aux[aux["patient.codi_postal"] > 0 & aux["patient.codi_postal"] < 100000, ]
    //}



    aggregation_filter.push(
        {
          $lookup: {
            from: 'patients',
            localField: 'id_pacient',
            foreignField: 'id_pacient',
            as: 'patient'
          }
        },
        {
          $unwind: {
            path: "$patient"
          }
        }
    )


    // _id are not required
    let fields_filter = { "$project": { _id: 0 } }

    // to improve performance it is better to select the fields needed instead of returning all
    /**
     * {
     * "year_max":2013,
     * "year_min":2012,
     * "filters":{
     *   fields":["field_name1",...]
     *  }
     *  }
     * */

    if (options.filters !== undefined) {
      if (options.filters.fields !== undefined) {
        options.filters.fields.forEach(function (field) {
          fields_filter["$project"][field] = 1
        });
      }
    }

    aggregation_filter.push(fields_filter)



    return new Promise((resolve, reject) => {
      tumors_db.Tumors.aggregate(aggregation_filter).then(_matrix => {
        resolve(_matrix)
      })
    })
  }


  const getByYears = (req) => {
    console.log(req.params)
    return new Promise((resolve, reject) => {
      tumors_db.Tumors.find().then(_matrix => {
        resolve(_matrix)
      })
    })
  }

  const getInicidenceByCounties = (options) => {

    var year = "2012"

    console.log(options)

    if (options.year) {
      year = options.year
      console.log(year)
    }

    console.log(year)


    var aggregation_filter = [
      {
        '$lookup': {
          'from': 'tumors',
          'localField': 'id_pacient',
          'foreignField': 'id_pacient',
          'as': 'tumors'
        }
      },
      { $match: { "morf": { "$ne": "M-80903" } } },
      { $match: { "morf": { "$ne": "M-80913" } } },
      { $match: { "morf": { "$ne": "M-80923" } } },
      { $match: { "morf": { "$ne": "M-80973" } } },
      { $match: { "morf": { "$ne": "M-80933" } } },
      { $match: { "morf": { "$ne": "M-80943" } } },
      { $match: { "morf": { "$ne": "M-80953" } } },
      { $match: { "morf": { "$ne": "M-80983" } } }
    ]
    if (options.year) {
      aggregation_filter.push(
          {
            $match: {
              "tumors.data_inc_pobl": {
                "$gte": new Date(options.year, 1, 1),
                "$lt": new Date(options.year + 1, 1, 1)
              }
            }
          })
    }


    if (options.loc3) {
      aggregation_filter.push(
          {
            '$match': {
              'tumors.loc3': options.loc3
            }
          })
    }

    aggregation_filter.push(
        {
          $addFields: {
            codi_postal: {
              $convert: {
                input: '$codi_postal',
                to: 'string'
              }
            }
          }
        }, {
          $lookup: {
            from: 'poblacions',
            localField: 'codi_postal',
            foreignField: 'codi_postal',
            as: 'poblacio'
          }
        }, {
          $unwind: {
            path: '$poblacio'
          }
        })
    aggregation_filter.push(
        {
          $addFields: {
            poblacio_n: '$poblacio.poblacio_any_' + year
          }
        }
    )
    aggregation_filter.push(
        {
          $lookup: {
            from: 'comarques',
            localField: 'poblacio.nom_poblacio',
            foreignField: 'Nom',
            as: 'comarca'
          }
        }, {
          $unwind: {
            path: '$comarca'
          }
        },
        {
          $addFields: {
            comarca: '$comarca.Comarca',
            poblacio: '$poblacio.nom_poblacio'
          }
        }, {
          $match: {
            comarca : { $nin : ["Solsonès", "Cerdanya"] }
          }
        },
        {
          $group: {
            _id: {
              comarca: '$comarca',
              poblacio: '$poblacio'
            },
            poblacio: {
              $max: '$poblacio_n'
            },
            count_pacient: {
              $sum: 1
            }
          }
        }, {
          $group: {
            _id: '$_id.comarca',
            poblacio: {
              $sum: '$poblacio'
            },
            count: {
              $sum: '$count_pacient'
            }
          }
        }
    )


    return new Promise((resolve, reject) => {
      incidence_db.Incidence.aggregate(aggregation_filter).then(_matrix => {
        resolve(_matrix)
      })
    })
  }


  const getEvolutionDidac = (options) => {
    console.log(options)

    var aggregation_filter = [{ $match: { "morf": { "$ne": "M-80903" } } },
      { $match: { "morf": { "$ne": "M-80913" } } },
      { $match: { "morf": { "$ne": "M-80923" } } },
      { $match: { "morf": { "$ne": "M-80973" } } },
      { $match: { "morf": { "$ne": "M-80933" } } },
      { $match: { "morf": { "$ne": "M-80943" } } },
      { $match: { "morf": { "$ne": "M-80953" } } },
      { $match: { "morf": { "$ne": "M-80983" } } }]

    if (options.loc3) {
      aggregation_filter.push(
          {
            '$match': {
              'loc3': options.loc3
            }
          })
    }

    if (options.sexe) {
      aggregation_filter.push(
          {
            '$match': {
              'sexe': parseInt(options.sexe)
            }
          })
    }

    var age_min = 0
    var age_max = 120

    if (options.age_min) {
      age_min = options.age_min
    }

    if (options.age_max) {
      age_max = options.age_max
    }

    aggregation_filter.push({
      '$match': {
        'age': {
          '$gte': parseInt(age_min), 
          '$lte': parseInt(age_max)
        }
      }
    },{
      '$match': {
        'codi_postal': {
          '$gte': 25000, 
          '$lte': 25999
        }
      }
    })


    aggregation_filter.push(
        {
          '$project': {
            'year': {
              '$toInt': {
                '$dateToString': {
                  'format': '%Y',
                  'date': '$data_inc_pobl'
                }
              }
            },
            'year_s' : {
              '$dateToString': {
                'format': '%Y',
                'date': '$data_inc_pobl'
              }
            }
          }
        }, 
        {
          '$group': {
            '_id': {
              'year': '$year',
              'year_s': '$year_s'
            },
            'cases': {
              '$sum': 1
            }
          }
        },
        {
          '$sort': {
            '_id': 1
          }
        }
    )

    return new Promise((resolve, reject) => {
      tumors_db.Tumors.aggregate(aggregation_filter).then(_matrix => {
        resolve(_matrix)
      })
    })
  }


  const getEvolutonData = (options) => {

    console.log(options)
    var aggregation_filter = [
      { $match: { "morf": { "$ne": "M-80903" } } },
      { $match: { "morf": { "$ne": "M-80913" } } },
      { $match: { "morf": { "$ne": "M-80923" } } },
      { $match: { "morf": { "$ne": "M-80973" } } },
      { $match: { "morf": { "$ne": "M-80933" } } },
      { $match: { "morf": { "$ne": "M-80943" } } },
      { $match: { "morf": { "$ne": "M-80953" } } },
      { $match: { "morf": { "$ne": "M-80983" } } },
      {
        $lookup: {
          from: 'patients',
          localField: 'id_pacient',
          foreignField: 'id_pacient',
          as: 'patient'
        }
      },
      {
        $unwind: {
          path: "$patient"
        }
      }
    ]

    aggregation_filter.push(
        {
          $addFields: {
            "age": {
              $toInt: { $subtract: ["$year", { $year: { $toDate: "$patient.data_naix" } }] }
            }
          }
        }
    )

    if (options.loc3) {
      aggregation_filter.push(
          {
            '$match': {
              'loc3': options.loc3
            }
          })
    }
    if (options["age_min"] !== undefined) { // age_min, age_max
      aggregation_filter.push(
          {
            '$match': {
              "age": {
                "$gte": parseInt(options.age_min),
                "$lte": parseInt(options.age_max),
              }
            }
          })
    }


    if (options["cp_min"] !== undefined) { // cp_min, cp_max
      aggregation_filter.push(
          {
            '$match': {
              "patient.codi_postal": {
                $gte: parseInt(options.cp_min),
                $lte: parseInt(options.cp_max)
              }
            }
          })
    }

    if (options["sexe"] !== undefined) { // sexe
      aggregation_filter.push(
          {
            '$match': {
              "patient.sexe": parseInt(options.sexe)
            }
          })
    }


    aggregation_filter.push(
        {
          $addFields: {
            year: { $year: { $toDate: "$data_inc_pobl" } }
          }
        },
        {
          $group: {
            _id: {
              year: '$year',
            },
            year: {
              $max: '$year'
            },
            cases: {
              $sum: 1
            }
          }
        },
        {
          $sort: {
            year: 1
          }
        }
    )

    return new Promise((resolve, reject) => {
      evolution_db.Evolution.aggregate(aggregation_filter).then(_matrix => {
        resolve(_matrix)
      })
    })
  }


  const getSubsequents = () => {

    console.log("In")

    return new Promise((resolve, reject) => {
      tumors_db.Tumors.find().then(_matrix => {
        resolve(_matrix)
      })
    })
  }

  const getOverweight = (options) => {
    console.log("In overweight")
    var aggregate_filter = [
      {
        '$match': {
          'imc': {
            '$gt': 24.9,
            '$lte': 29.9
          }
        }
      }, {
        '$group': {
          '_id': null,
          'overweight': {
            '$sum': 1
          }
        }
      }
    ]

    return new Promise((resolve, reject) => {
      patients_db.Patients.aggregate(aggregate_filter).then(_matrix => {
        resolve(_matrix)
      })
    })
  }

  const getObesity = (options) => {
    console.log("In obesity")
    var aggregate_filter = [
      {
        '$match': {
          'imc': {
            '$gt': 30
          }
        }
      }, {
        '$group': {
          '_id': null,
          'obesity': {
            '$sum': 1
          }
        }
      }
    ]

    return new Promise((resolve, reject) => {
      patients_db.Patients.aggregate(aggregate_filter).then(_matrix => {
        resolve(_matrix)
      })
    })
  }


  const getAlcoholism = (options) => {

    var aggregate_filter = [
      {
        '$match': {
          'alcoholisme': 'Si'
        }
      }, {
        '$group': {
          '_id': null,
          'alcoholism': {
            '$sum': 1
          }
        }
      }
    ]

    return new Promise((resolve, reject) => {
      patients_db.Patients.aggregate(aggregate_filter).then(_matrix => {
        resolve(_matrix)
      })
    })
  }

  const getSmoking = (options) => {

    var aggregate_filter = [
      {
        '$match': {
          'fumador': 'Si'
        }
      }, {
        '$group': {
          '_id': null,
          'fumador': {
            '$sum': 1
          }
        }
      }
    ]

    return new Promise((resolve, reject) => {
      patients_db.Patients.aggregate(aggregate_filter).then(_matrix => {
        resolve(_matrix)
      })
    })
  }

  const getDiabetes = (options) => {

    var aggregate_filter = [
      {
        '$match': {
          'diabetes': 'Si'
        }
      }, {
        '$group': {
          '_id': null,
          'diabetes': {
            '$sum': 1
          }
        }
      }
    ]

    return new Promise((resolve, reject) => {
      patients_db.Patients.aggregate(aggregate_filter).then(_matrix => {
        resolve(_matrix)
      })
    })
  }

  const getCim10List = (options) => {

    var aggregate_filter = [
      {
        '$project': {
          'item': {
            '$concat': [
              '$CAUSA10', ' - ', '$cim10_descr'
            ]
          },
          'causa10': '$CAUSA10',
          'cim10_descr': '$cim10_descr'
        }
      }, {
        '$group': {
          '_id': {
            'item': '$item',
            'causa10': '$causa10',
            'cim10_descr': '$cim10_descr'
          },
          'n_causa10': {
            '$sum': 1
          }
        }
      }, {
        '$sort': {
          'n_causa10': -1
        }
      }
    ]

    return new Promise((resolve, reject) => {
      mortality_db.Mortality.aggregate(aggregate_filter).then(_matrix => {
        resolve(_matrix)
      })
    })
  }

  const getAgeGroupsCountMortality = (req) => {

    var aggregate_filter = []

    aggregate_filter.push(
        {
          '$match': {
            'ANYD': {
              '$gte': Number(req.params['any_inici']),
              '$lte': Number(req.params['any_fi'])
            }
          }
        }
    )

    if (req.params['sexe'] == 'Female' || req.params['sexe'] == 'Male') {
      aggregate_filter.push(
          {
            '$match': {
              'sexe_descr': req.params['sexe']
            }
          })
    }

    if (req.params['location'] != 'A') {
      aggregate_filter.push(
          {
            '$match': {
              'CAUSA10': req.params['location']
            }
          })
    }

    aggregate_filter.push(
        {
          '$group': {
            '_id': {
              'age_group': '$age_group',
              'sexe_descr': '$sexe_descr'
            },
            'count': {
              '$sum': 1
            }
          }
        }, {
          '$sort': {
            '_id': 1
          }
        }
    )

    return new Promise((resolve, reject) => {
      mortality_db.Mortality.aggregate(aggregate_filter).then(_matrix => {
        resolve(_matrix)
      })
    })
  }

  const getMortalityCasesBySex = (req) => {

    var aggregate_filter = []
    var any_inici = Number(req.params['any_inici'])
    var any_fi = Number(req.params['any_fi'])

    if (req.params['sexe'] == 'Female' || req.params['sexe'] == 'female' || req.params['sexe'] == 'Male' || req.params['sexe'] == 'male') {
      aggregate_filter.push(
          {
            '$match': {
              'ANYD': {
                '$gte': any_inici,
                '$lte': any_fi
              },
              'sexe_descr': req.params['sexe']
            }
          }
      )
    } else {
      aggregate_filter.push(
          {
            '$match': {
              'ANYD': {
                '$gte': any_inici,
                '$lte': any_fi
              }
            }
          }
      )
    }

    console.log(req.params)

    aggregate_filter.push(
        {
          '$project': {
            'item': {
              '$concat': [
                '$CAUSA10', ' - ', '$cim10_descr'
              ]
            },
            'causa10': '$CAUSA10',
            'sexe': '$sexe',
            'cim10_descr': '$cim10_descr'
          }
        }, {
          '$group': {
            '_id': {
              'item': '$item',
              'causa10': '$causa10',
              'cim10_descr': '$cim10_descr'
            },
            'n_causa10': {
              '$sum': 1
            }
          }
        }, {
          '$sort': {
            'n_causa10': -1
          }
        }
    )

    return new Promise((resolve, reject) => {
      mortality_db.Mortality.aggregate(aggregate_filter).then(_matrix => {
        resolve(_matrix)
      })
    })
  }


  const getEvolutionByYear = (req) => {

    var aggregate_filter = []

    if (req.params['sexe'] == 'Female' || req.params['sexe'] == 'Male') {
      aggregate_filter.push(
          {
            '$match': {
              'sexe_descr': req.params['sexe']
            }
          })
    }

    if (req.params['location'] != 'A') {
      aggregate_filter.push(
          {
            '$match': {
              'CAUSA10': req.params['location']
            }
          })
    }


    console.log(req.params)

    aggregate_filter.push(
        {
          '$group': {
            '_id': {
              'any': '$ANYD'
            },
            'any_n': {
              '$sum': 1
            }
          }
        }, {
          '$sort': {
            '_id': 1
          }
        }
    )

    return new Promise((resolve, reject) => {
      mortality_db.Mortality.aggregate(aggregate_filter).then(_matrix => {
        resolve(_matrix)
      })
    })
  }


  const getMortalityCasesGroupBySex = (req) => {
    console.log(req.params)

    var aggregate_filter = [
      {
        '$match': {
          'ANYD': {
            '$gte': parseInt(req.params['year_min']),
            '$lte': parseInt(req.params['year_max'])
          }
        }
      }, {
        '$group': {
          '_id': {
            'sexe': '$sexe_descr'
          },
          'total': {
            '$sum': 1
          }
        }
      },
      {
        '$sort': {
          '_id': -1
        }
      }
    ]


    return new Promise((resolve, reject) => {
      mortality_db.Mortality.aggregate(aggregate_filter).then(_matrix => {
        resolve(_matrix)
      })
    })
  }


  const getTotalCancerCasesBySex = (options) => {

    var data_min = new Date(2012, 1, 1)
    var data_max = new Date(2016, 12, 31)

    console.log(options)

    if (options.year_min) {
      data_min = new Date(options.year_min, 1, 1)
    }

    if (options.year_max) {
      data_max = new Date(options.year_max, 12, 31)
    }

    var age_min = 0
    var age_max = 120

    if (options.age_min) {
      age_min = options.age_min
    }

    if (options.age_max) {
      age_max = options.age_max
    }


    var aggregate_filter = [
      {
        '$match': {
          'data_inc_pobl': {
            '$gte': data_min,
            '$lte': data_max
          }
        }
      }, 
      {
        '$match': {
          'age': {
            '$gte': parseInt(age_min), 
            '$lte': parseInt(age_max)
          }
        }
      },
      {
        '$match': {
          'codi_postal': {
            '$gte': 25000, 
            '$lte': 25999
          }
        }
      },{
        '$group': {
          '_id': '$sexe',
          'total': {
            '$sum': 1
          }
        }
      }
    ]

    return new Promise((resolve, reject) => {
      tumors_db.Tumors.aggregate(aggregate_filter).then(_matrix => {
        resolve(_matrix)
      })
    })


  }

  const getCancerCasesByYearSex = (options) => {
    var data_min = new Date(2012, 1, 1)
    var data_max = new Date(2016, 12, 31)

    console.log(options)

    if (options.year_min) {
      data_min = new Date(options.year_min, 1, 1)
    }

    if (options.year_max) {
      data_max = new Date(options.year_max, 12, 31)
    }

    var aggregate_filter = [{ $match: { "morf": { "$ne": "M-80903" } } },
      { $match: { "morf": { "$ne": "M-80913" } } },
      { $match: { "morf": { "$ne": "M-80923" } } },
      { $match: { "morf": { "$ne": "M-80973" } } },
      { $match: { "morf": { "$ne": "M-80933" } } },
      { $match: { "morf": { "$ne": "M-80943" } } },
      { $match: { "morf": { "$ne": "M-80953" } } },
      { $match: { "morf": { "$ne": "M-80983" } } }]

    if (options.sex) {
      aggregate_filter.push(
          {
            '$match': {
              'sexe': parseInt(options.sex)
            }
          }
      )
    }

    var age_min = 0
    var age_max = 120

    if (options.age_min) {
      age_min = options.age_min
    }

    if (options.age_max) {
      age_max = options.age_max
    }

    aggregate_filter.push(
        {
          '$match': {
            'data_inc_pobl': {
              '$gte': data_min,
              '$lte': data_max
            }
          }
        },
        {
          '$match': {
            'codi_postal': {
              '$gte': 25000, 
              '$lte': 25999
            }
          }
        },
        {
          '$match': {
            'age': {
              '$gte': parseInt(age_min), 
              '$lte': parseInt(age_max)
            }
          }
        },
        {
          '$group': {
            '_id': {
              'loc3': '$loc3',
              'descr': '$loc3_desc'
            },
            'cases': {
              '$sum': 1
            }
          }
        },
        {
          '$sort': {
            '_id': 1
          }
        }
    )

    return new Promise((resolve, reject) => {
      tumors_db.Tumors.aggregate(aggregate_filter).then(_matrix => {
        resolve(_matrix)
      })
    })


  }


  const getAvgAgeSex = (options) => {

    var data_min = new Date(2012, 1, 1)
    var data_max = new Date(2016, 12, 31)

    console.log(options)

    if (options.year_min) {
      data_min = new Date(options.year_min, 1, 1)
    }

    if (options.year_max) {
      data_max = new Date(options.year_max, 12, 31)
    }

    var aggregate_filter = [{ $match: { "morf": { "$ne": "M-80903" } } },
      { $match: { "morf": { "$ne": "M-80913" } } },
      { $match: { "morf": { "$ne": "M-80923" } } },
      { $match: { "morf": { "$ne": "M-80973" } } },
      { $match: { "morf": { "$ne": "M-80933" } } },
      { $match: { "morf": { "$ne": "M-80943" } } },
      { $match: { "morf": { "$ne": "M-80953" } } },
      { $match: { "morf": { "$ne": "M-80983" } } }]

    if (options.sex) {
      aggregate_filter.push(
          {
            '$match': {
              'sexe': parseInt(options.sex)
            }
          }
      )
    }

    aggregate_filter.push(
        {
          '$match': {
            'data_inc_pobl': {
              '$gte': data_min,
              '$lte': data_max
            }
          }
        },
        {
          '$match': {
            'codi_postal': {
              '$gte': 25000, 
              '$lte': 25999
            }
          }
        },
        {
          '$group': {
            '_id': "age",
            'avgAge': {
              '$avg': "$age"
            }
          }
        },
        {
          '$project': {
            'ageS': {
              '$toString': '$avgAge'
            }
          }
        }
    )


    return new Promise((resolve, reject) => {
      tumors_db.Tumors.aggregate(aggregate_filter).then(_matrix => {
        resolve(_matrix)
      })
    })
  }


  const getAgeGroupsCount = (options) => {

    var data_min = new Date(2012, 1, 1)
    var data_max = new Date(2016, 12, 31)

    console.log(options)

    if (options.year_min) {
      data_min = new Date(options.year_min, 1, 1)
    }

    if (options.year_max) {
      data_max = new Date(options.year_max, 12, 31)
    }

    var age_min = 0
    var age_max = 120

    if (options.age_min) {
      var age_min = options.age_min
    }

    if (options.age_max) {
      var age_max = options.age_max
    }




    var aggregate_filter = [{ $match: { "morf": { "$ne": "M-80903" } } },
      { $match: { "morf": { "$ne": "M-80913" } } },
      { $match: { "morf": { "$ne": "M-80923" } } },
      { $match: { "morf": { "$ne": "M-80973" } } },
      { $match: { "morf": { "$ne": "M-80933" } } },
      { $match: { "morf": { "$ne": "M-80943" } } },
      { $match: { "morf": { "$ne": "M-80953" } } },
      { $match: { "morf": { "$ne": "M-80983" } } }]

    if (options.sex) {
      aggregate_filter.push(
          {
            '$match': {
              'sexe': parseInt(options.sex)
            }
          }
      )
    }

    if (options.loc3) {
      aggregate_filter.push(
        {
          '$match': {
            'loc3': options.loc3
          }
        }
      )
    }


    aggregate_filter.push(
        {
          '$match': {
            'data_inc_pobl': {
              '$gte': data_min,
              '$lte': data_max
            }
          }
        },
        {
          '$match': {
            'age': {
              '$gte': parseInt(age_min), 
              '$lte': parseInt(age_max)
            }
          }
        },
        {
          '$match': {
            'codi_postal': {
              '$gte': 25000, 
              '$lte': 25999
            }
          }
        },
        {
          '$group': {
            '_id': {
              'age_group': '$age_group',
              'sexe': '$sexe_desc'
            },
            'count': {
              '$sum': 1
            }
          }
        }, {
          '$sort': {
            '_id': 1
          }
        }
    )

    return new Promise((resolve, reject) => {
      tumors_db.Tumors.aggregate(aggregate_filter).then(_matrix => {
        resolve(_matrix)
      })
    })
  }

  const getLocationCasesGroupBySex = (options) => {

    var data_min = new Date(2012, 1, 1)
    var data_max = new Date(2016, 12, 31)

    console.log(options)

    if (options.year_min) {
      data_min = new Date(options.year_min, 1, 1)
    }

    if (options.year_max) {
      data_max = new Date(options.year_max, 12, 31)
    }

    var aggregate_filter = [{ $match: { "morf": { "$ne": "M-80903" } } },
      { $match: { "morf": { "$ne": "M-80913" } } },
      { $match: { "morf": { "$ne": "M-80923" } } },
      { $match: { "morf": { "$ne": "M-80973" } } },
      { $match: { "morf": { "$ne": "M-80933" } } },
      { $match: { "morf": { "$ne": "M-80943" } } },
      { $match: { "morf": { "$ne": "M-80953" } } },
      { $match: { "morf": { "$ne": "M-80983" } } },
      {
        '$match': {
          'data_inc_pobl': {
            '$gte': data_min,
            '$lte': data_max
          }
        }
      },
      {
        '$match': {
          'codi_postal': {
            '$gte': 25000, 
            '$lte': 25999
          }
        }
      },
      {
        '$group': {
          '_id': {
            'sex': '$sexe_desc',
            'location_desc': '$loc3_desc',
            'loc3': '$loc3'
          },
          'cases': {
            '$sum': 1
          }
        }
      }, {
        '$sort': {
          'cases': -1,
          '_id': 1
        }
      }

    ]


    return new Promise((resolve, reject) => {
      tumors_db.Tumors.aggregate(aggregate_filter).then(_matrix => {
        resolve(_matrix)
      })
    })

  }

  const getIncidenceByRegion = (options) => {

    console.log(options)

    var aggregate_filter = []

    if (options.loc3) {
      aggregate_filter.push(
        {
          '$match': {
            'loc3': options.loc3
          }
        } 
      )
    }


    if (options.year) {
      var data_min = new Date(options.year, 1, 1)
      var data_max = new Date(options.year, 12, 31)


      aggregate_filter.push(
        {
          '$match': {
            'data_inc_pobl': {
              '$gte': data_min,
              '$lte': data_max
            }
          }

        }
      )
    }


    aggregate_filter.push({
      '$lookup': {
        'from': 'comarques_poblacio', 
        'localField': 'comarca', 
        'foreignField': 'nom_comarca', 
        'as': 'comarques'
      }
    }, {
      '$unwind': {
        'path': '$comarques'
      }
    }, {
      '$addFields': {
        'poblacio': '$comarques.'+options.year
      }
    }, {
      '$group': {
        '_id': {
          'comarca': '$comarca', 
          'poblacio': '$poblacio'
        }, 
        'count': {
          '$sum': 1
        }
      }
    }, {
      '$project': {
        '_id': '$_id', 
        'count': '$count', 
        'incidence': {
          '$multiply': [
            {
              '$divide': [
                '$count', '$_id.poblacio'
              ]
            }, 100000
          ]
        }
      }
    }, {
      '$match': {
        '_id': {
          '$ne': null
        }
      }
    }, {
      '$match': {
        '_id': {
          '$ne': 'Cerdanya'
        }
      }
    }, {
      '$sort': {
        '_id': 1
      }
    })


    return new Promise((resolve, reject) => {
      tumors_db.Tumors.aggregate(aggregate_filter).then(_matrix => {
        resolve(_matrix)
      })
    })
    
  }


  const disconnect = () => {
    db.close()
  }

  return Object.create({
    getYear,
    getAllByYearData,
    getInicidenceByCounties,
    getAllProvinces,
    getLoc3,
    getEvolutonData,
    getSubsequents,
    getOverweight,
    getObesity,
    getAlcoholism,
    getSmoking,
    getDiabetes,
    getCim10List,
    getAgeGroupsCountMortality,
    getMortalityCasesBySex,
    getEvolutionByYear,
    getEvolutionDidac,
    getByYears,
    getMortalityCasesGroupBySex,
    getTotalCancerCasesBySex,
    getCancerCasesByYearSex,
    getAvgAgeSex,
    getAgeGroupsCount,
    getLocationCasesGroupBySex,
    getIncidenceByRegion,
    disconnect
  })
}

const connect = (connection) => {
  return new Promise((resolve, reject) => {
    if (!connection) {
      reject(new Error('connection db not supplied!'))
    }
    resolve(repository(connection))
  })
}

module.exports = Object.assign({}, { connect })


