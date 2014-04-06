Dolos = require '../src/dolos'

Dolos.registerStore('gaia', (command, object, overrides) ->
  console.log("command", command)
  console.log("object", object)
  console.log("overrides", overrides)
)

Dolos.define('client', {
  build: {
    x: 'abc'
    y: 'hihg'
  },
  traits: {
    'enabled': {
      enabled: true
      y: false
      simple: Dolos.Fake.sequence('x')
      parallel1: Dolos.Fake.sequence('a')
      parallel2: Dolos.Fake.sequence('a')
      parallel4: Dolos.Fake.sequence('d', (index) -> "G#{index}")
    },
    'disabled': ->
      @foo = Dolos.Fake.sequence('a')()
      return
  },
  store: (object) ->
    console.log "Storing in Gaia"
    Dolos.store('gaia', "COMMAND", object, "OVER")
})

Dolos.create('client')
