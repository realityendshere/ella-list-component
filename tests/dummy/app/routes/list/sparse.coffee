`import Ember from 'ember'`
`import EllaSparseArray from 'ella-sparse-array/lib/sparse-array'`

TOTAL_RECORDS = 600

didRequestFunctions = {
  didRequestLength: ->
    Ember.$.get('/api/note', {page: {offset: 0, limit: 1}}).then((response) =>
      @provideLength(response.meta.total)
    )

  didRequestRange: (range) ->
    Ember.$.get('/api/note', {page: {offset: range['start'], limit: range['length']}}).then((response) =>
      @provideLength(response.meta.total)
      @provideObjectsInRange(range, response['data'])
    )
}

SparseRoute = Ember.Route.extend
  setupController: (controller, model) ->
    controller.set('model', model)
    @_super(controller, model)

  model: ->
    EllaSparseArray.create(didRequestFunctions)


`export default SparseRoute`
