`import Ember from 'ember'`
`import EllaListableItemMixin from 'ella-list-component/components/ella-listable-item'`
`import EllaGridComponent from 'ella-list-component/components/ella-grid'`

computed = Ember.computed

EllaGridItemComponent = Ember.Component.extend EllaListableItemMixin,
  classNames: ['emberella-grid-item']

`export default EllaGridItemComponent`
