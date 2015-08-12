`import Ember from 'ember'`
`import StyleBindingsMixin from 'ella-burn-ins/mixins/style-bindings'`
`import EllaListComponent from 'ella-list-component/components/ella-list'`

computed = Ember.computed

EllaListReelComponent = Ember.Component.extend StyleBindingsMixin,
  classNames: ['ella-list-reel']

  styleBindings: ['height', 'width', 'position']

  height: computed.oneWay 'listView.totalHeight'

  width: '100%'

  position: 'relative'

  listView: computed('parentView', {
    get: ->
      @nearestOfType EllaListComponent
  })




`export default EllaListReelComponent`
