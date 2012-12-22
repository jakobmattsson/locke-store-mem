should = require 'should'
core = require 'locke-store-test'
memstore = require('./coverage').require('db')

noErr = (f) -> (err, rest...) ->
  should.not.exist err
  f(rest...)

it "should have a clean-method", (done) ->
  store = memstore.factory()
  store.createUser 'locke', 'email@test.com', { password: 'psspww' }, (err) ->
    store.createApp 'email@test.com', 'my-app', noErr ->
      store.getApps 'email@test.com', noErr (data) ->
        Object.keys(data).length.should.eql 1
        store.clean noErr ->
          store.getApps 'email@test.com', (err, data) ->
            err.should.eql "There is no user with the email 'email@test.com' for the app 'locke'"
            done()

core.runTests memstore.factory, (store, done) ->
  store.clean(done)
