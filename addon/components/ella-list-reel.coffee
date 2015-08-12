`import Ember from 'ember'`
`import EllaListableReelMixin from 'ella-list-component/components/ella-listable-reel'`
`import EllaListComponent from 'ella-list-component/components/ella-list'`

get = Ember.get
computed = Ember.computed

EllaListReelComponent = Ember.Component.extend EllaListableReelMixin,
  classNames: ['emberella-list-reel']

  listView: computed('parentView', {
    get: ->
      @nearestOfType EllaListComponent
  })

`export default EllaListReelComponent`
