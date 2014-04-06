Dolos = require '../src/dolos'

Dolos.define('complex', {

  build: (params) ->
    object = {}
    object.params = params
    object

  traits: {
    custom: (object, params) ->
      object.custom = Object.keys(params)
      object

  }
})

console.log Dolos.build('complex', {}, { foo: 'bar', bar: 'baz' })
###
prints
{
  params: {
    foo: 'bar',
    bar: 'baz'
  }
}
###
console.log Dolos.build('custom-complex', {}, { foo:'bar', bar: 'baz' })
###
prints
{
  params: {
    foo: 'bar',
    bar: 'baz'
  },
  custom: [ 'foo', 'bar' ]
}
###
