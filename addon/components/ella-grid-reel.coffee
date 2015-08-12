`import Ember from 'ember'`
`import EllaListableReelMixin from 'ella-list-component/components/ella-listable-reel'`
`import EllaGridComponent from 'ella-list-component/components/ella-grid'`

get = Ember.get
computed = Ember.computed

EllaGridReelComponent = Ember.Component.extend EllaListableReelMixin,
  classNames: ['emberella-grid-reel']

  listView: computed('parentView', {
    get: ->
      @nearestOfType EllaGridComponent
  })

`export default EllaGridReelComponent`
