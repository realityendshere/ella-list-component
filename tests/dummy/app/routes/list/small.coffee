`import Ember from 'ember'`

TOTAL_RECORDS = 5

smallArray = ->
  for i in [1..TOTAL_RECORDS]
    {
      "id": i,
      "note": "This is item " + i,
      "updatedAt": Date.now()
    }


SmallRoute = Ember.Route.extend
  setupController: (controller, model) ->
    controller.set('model', model)
    @_super(controller, model)

  model: ->
    smallArray()


`export default SmallRoute`
