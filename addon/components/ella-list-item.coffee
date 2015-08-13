`import Ember from 'ember'`
`import EllaListableItemMixin from 'ella-list-component/components/ella-listable-item'`
`import EllaListComponent from 'ella-list-component/components/ella-list'`

computed = Ember.computed

LIST_ITEM_CLASS = 'emberella-list-item'

EllaListItemComponent = Ember.Component.extend EllaListableItemMixin,
  classNames: [LIST_ITEM_CLASS]

  ###
    The seed for the fluctuated class name.

    For example, setting this property to `item-listing` would result in class
    names like `item-listing-0` and `item-listing-1`.

    @property fluctuateListingPrefix
    @type String
    @default 'emberella-list-item'
  ###
  fluctuateListingPrefix: LIST_ITEM_CLASS


`export default EllaListItemComponent`
