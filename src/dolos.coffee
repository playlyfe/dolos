_ = require 'lodash'
Faker = require 'Faker'
uuid = require 'node-uuid'

class Dolos

  @_definitions: {}
  @_persistence_strategies: {}
  @_sequences: {}
  ###
  Sample Configuration Object
  {
    model: <function>,
    build: <function/object>,
    traits: {
      <trait>: <function/object>
    }
    store: <function/string>
    hooks: {
      build: {
        after: <function>
      }
      create: {
        before: <function>
        after: <function>
      }
    }
  }
  ###
  @define: (name, config) ->
    @_definitions[name] = config

  @build: (name, attributes) ->

    parts = name.split('-').reverse()
    type = parts[0]
    traits = parts.slice(1)

    # Build the object using the build function or configuration object
    if not (definition = @_definitions[type])?
      throw new Error("Definition for #{type} not found")
    if not definition.build?
      throw new Error("Build configuration missing for #{type}")

    if _.isFunction(definition.build)
      object = definition.build.call(null)

    else if _.isObject(definition.build)
      object = {}
      for key, value of definition.build
        if _.isFunction(value)
          object[key] = value.call(object, type)
        else
          object[key] = _(value).cloneDeep()

    # Check for traits and apply them in reverse
    for trait in traits
      if not (trait_definition = definition.traits[trait])?
        throw new Error("Trait #{trait} not found on #{type}")

      if _.isFunction(trait_definition)
        trait_definition.call(object)

      else if _.isObject(trait_definition)
        for key, value of trait_definition
          if _.isFunction(value)
            object[key] = value.call(object, type)
          else
            object[key] = _(value).cloneDeep()

    # Apply attribute overrides
    for key, value of attributes
      object[key] = value

    # Apply Model constructor
    if definition.model? and _.isFunction(definition.model)
      object = definition.model(object)

    # Call build after hook
    if definition.hooks?.after?
      definition.hooks.after.call(null, object)

    object

  @create: (name, attributes, options) ->
    parts = name.split('-').reverse()
    type = parts[0]

    definition = @_definitions[type]
    if not definition.store?
      throw new Error('No persistence store registered')
    # Build the object
    object = Dolos.build(name, attributes)
    # Call create before hook

    if definition.hooks?.before?
      definition.hooks.before(object)

    # Call persistence strategy
    if _.isString(definition.store)
      if not (store = Dolos._persistence_strategies[definition.store])?
        throw new Error("Persistence store #{definition.store} not found")
      result = store(object, options)
    else if _.isFunction(definition.store)
      result = definition.store(object, options)

    # Call create after hook
    if definition.hooks?.after?
      result = result.then (object) -> definition.hooks.after(object)

    result

  @store: (name, args...) ->
    Dolos._persistence_strategies[name](args...)

  @registerStore: (store, storeFunction) ->
    if Dolos._persistence_strategies[store]
      throw new Error("Store #{store} has already be registered")
    Dolos._persistence_strategies[store] = storeFunction

  @Fake: _.extend({
    sequence: (sequence_name, generator) ->
      Dolos._sequences[sequence_name] ?= 0
      ->
        index = ++Dolos._sequences[sequence_name]
        if _.isFunction(generator)
          generator.call(@, index)
        else
          index
    UUID: {
      v1: (generator) ->
        ->
          id = uuid.v1()
          if _.isFunction(generator)
            generator.call(@, id)
          else
            id

      v4: (generator) ->
        ->
          id = uuid.v4()
          if _.isFunction(generator)
            generator.call(@, id)
          else
            id
    }
  }, Faker)


module.exports = Dolos
