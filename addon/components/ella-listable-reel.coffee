`import Ember from 'ember'`
`import StyleBindingsMixin from 'ella-burn-ins/mixins/style-bindings'`

get = Ember.get
computed = Ember.computed

EllaListableReelMixin = Ember.Mixin.create(StyleBindingsMixin, {
  styleBindings: ['height', 'width', 'position', 'min-height']

  height: computed.oneWay 'listView.totalHeight'

  'min-height': computed('listView.rowHeight', ->
    get(@, 'listView.rowHeight') * 2
  )

  width: '100%'

  position: 'relative'
})

`export default EllaListableReelMixin`
