`import Ember from 'ember'`

IndexRoute = Ember.Route.extend
  redirect: -> @transitionTo 'list.small'

`export default IndexRoute`
