`import Ember from 'ember'`
`import EllaListableItemMixin from 'ella-list-component/components/ella-listable-item'`
`import EllaListComponent from 'ella-list-component/components/ella-list'`

computed = Ember.computed

EllaListItemComponent = Ember.Component.extend EllaListableItemMixin,
  classNames: ['emberella-list-item']

`export default EllaListItemComponent`
