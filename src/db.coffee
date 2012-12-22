database = null
rootAppName = 'locke'

clean = (callback) ->
  database = {}
  database[rootAppName] = { users: {} }
  callback() if callback

clean()

noUser = (app, email) -> "There is no user with the email '#{email}' for the app '#{app}'"
noApp = (app) -> "Could not find an app with the name '#{app}'"
noNullPassword = -> 'Password cannot be null'
noEmptyPassword = -> 'Password must be a non-empty string'

exports.factory = ->

  comparePassword: (app, email, password, callback) ->
    process.nextTick ->
      return callback(noApp(app)) if !database[app]?
      return callback(noUser(app, email)) if !database[app].users[email]?
      callback(null, password == database[app].users[email].data.password)

  compareToken: (app, email, type, name, callback) ->
    process.nextTick ->
      return callback(noApp(app)) if !database[app]?
      return callback(noUser(app, email)) if !database[app].users[email]?
      tt = database[app].users[email]?.tokens?[type]?.list?[name]
      return callback('Incorrect token') if !tt?
      callback(null, tt.data)

  addToken: (app, email, type, name, tokenData, callback) ->
    process.nextTick ->
      return callback(noApp(app)) if !database[app]?
      return callback(noUser(app, email)) if !database[app].users[email]?
      database[app].users[email].tokens ?= {}
      database[app].users[email].tokens[type] ?= {}
      database[app].users[email].tokens[type].list ?= {}
      database[app].users[email].tokens[type].list[name] = { data: tokenData }
      callback()

  removeToken: (app, email, type, name, callback) ->
    process.nextTick ->
      return callback(noApp(app)) if !database[app]?
      return callback(noUser(app, email)) if !database[app].users[email]?
      database[app].users[email].tokens ?= {}
      database[app].users[email].tokens[type] ?= {}
      database[app].users[email].tokens[type].list ?= {}
      delete database[app].users[email].tokens[type].list[name]
      callback()

  removeAllTokens: (app, email, type, callback) ->
    process.nextTick ->
      return callback(noApp(app)) if !database[app]?
      return callback(noUser(app, email)) if !database[app].users[email]?
      database[app].users[email].tokens ?= {}
      database[app].users[email].tokens[type] ?= {}
      delete database[app].users[email].tokens[type]
      callback()

  setUserData: (app, email, userData, callback) ->
    process.nextTick ->
      return callback(noApp(app)) if !database[app]?
      return callback(noUser(app, email)) if !database[app].users[email]?

      newDbData = database[app].users[email].data
      Object.keys(userData).forEach (key) ->
        newDbData[key] = userData[key]

      return callback(noNullPassword()) if !newDbData.password?
      return callback(noEmptyPassword()) if typeof newDbData.password != 'string' || newDbData.password == ''

      database[app].users[email].data = newDbData
      callback null, database[app].users[email].data

  getUser: (app, email, callback) ->
    process.nextTick ->
      return callback(noApp(app)) if !database[app]?
      callback null, database[app].users[email]?.data

  createUser: (app, email, userData, callback) ->
    return callback(noNullPassword()) if !userData?.password?
    return callback(noEmptyPassword()) if typeof userData.password != 'string' || userData.password == ''

    process.nextTick ->
      return callback(noApp(app)) if !database[app]?
      return callback("User '#{email}' already exists for the app '#{app}'") if database[app].users[email]?
      database[app].users[email] = { data: userData }
      callback null, database[app].users[email].data

  removeUser: (app, email, callback) ->
    process.nextTick ->
      return callback(noApp(app)) if !database[app]?
      return callback(noUser(app, email)) if !database[app].users[email]?
      delete database[app].users[email]
      callback()

  createApp: (email, app, callback) ->
    process.nextTick ->
      if !database[rootAppName].users[email]?
        callback(noUser(rootAppName, email))
      else if database[app]?
        callback("App name '#{app}' is already in use")
      else
        database[app] = { users: {}, owner: email }
        callback()

  getApps: (email, callback) ->
    process.nextTick ->
      return callback(noUser(rootAppName, email)) if !database[rootAppName].users[email]?

      res = {}
      Object.keys(database).forEach (app) ->
        if database[app].owner? && database[app].owner == email
          res[app] = {
            userCount: Object.keys(database[app].users).length
          }
      callback(null, res)

  deleteApp: (app, callback) ->
    process.nextTick ->
      return callback("It is not possible to delete the app '#{rootAppName}'") if app == rootAppName
      return callback(noApp(app)) if !database[app]?
      delete database[app]
      callback()

  clean: clean
