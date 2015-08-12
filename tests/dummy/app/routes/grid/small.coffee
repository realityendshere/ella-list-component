`import Ember from 'ember'`

SmallRoute = Ember.Route.extend
  setupController: (controller, model) ->
    controller.set('model', model)
    @_super(controller, model)

  model: ->
    [
      {
        "id": 1,
        "note": "This is item 1",
        "updatedAt": Date.now()
      }
    ]


`export default SmallRoute`
