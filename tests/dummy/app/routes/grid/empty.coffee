`import Ember from 'ember'`

EmptyRoute = Ember.Route.extend
  setupController: (controller, model) ->
    controller.set('model', model)
    @_super(controller, model)

  model: ->
    Ember.A()


`export default EmptyRoute`
