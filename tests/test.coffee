should = require 'should'
core = require 'locke-store-test'
memstore = require('./coverage').require('db')

noErr = (f) -> (err, rest...) ->
  should.not.exist err
  f(rest...)

isError = (err, msg) ->
  err.should.be.an.instanceof Error
  err.message.should.eql msg
  err.toString().should.eql "Error: #{msg}"

it "should have a clean-method", (done) ->
  store = memstore.factory()
  store.createUser 'locke', 'email@test.com', { password: 'psspww' }, (err) ->
    store.createApp 'email@test.com', 'my-app', noErr ->
      store.getApps 'email@test.com', noErr (data) ->
        Object.keys(data).length.should.eql 1
        store.clean noErr ->
          store.getApps 'email@test.com', (err, data) ->
            isError(err, "There is no user with the email 'email@test.com' for the app 'locke'")
            done()

core.runTests memstore.factory, (store, done) ->
  store.clean(done)
