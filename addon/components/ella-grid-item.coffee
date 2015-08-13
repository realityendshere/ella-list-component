`import Ember from 'ember'`
`import EllaListableItemMixin from 'ella-list-component/components/ella-listable-item'`
`import EllaGridComponent from 'ella-list-component/components/ella-grid'`

get = Ember.get
set = Ember.set
computed = Ember.computed

GRID_ITEM_CLASS = 'emberella-grid-item'


EllaGridItemComponent = Ember.Component.extend EllaListableItemMixin,
  classNames: [GRID_ITEM_CLASS]

  styleBindings: ['height', 'width', 'position', 'top', 'display', 'pointer-events', 'left']

  columns: computed.oneWay 'listView.columns'
  margin: computed.oneWay 'listView.margin'

  ###
    Give each child listing an additional class name based on the child's
    content index.

    Defaults to column count.

    @property fluctuateListing
    @type Integer
  ###
  fluctuateListing: computed.oneWay 'columns'

  ###
    The seed for the fluctuated class name.

    For example, setting this property to `item-listing` would result in class
    names like `item-listing-0` and `item-listing-1`.

    @property fluctuateListingPrefix
    @type String
    @default 'emberella-grid-item'
  ###
  fluctuateListingPrefix: GRID_ITEM_CLASS

  ###
    In pixels, calculate the distance from the top this listing should be
    positioned within the scrolling list.

    Adjusts styling to account for the number of columns in the grid.

    @property top
    @type Integer
  ###
  top: computed('contentIndex', 'height', 'columns', {
    get: ->
      columns = get(@, 'columns')
      columns = 1 if columns < 1
      Math.floor(get(@, 'contentIndex') / columns) * get(@, 'height')
  })

  ###
    In pixels, calculate the distance from the left this listing should be
    positioned within the scrolling list.

    @property left
    @type Integer
  ###
  left: computed('contentIndex', 'columns', 'columnWidth', {
    get: ->
      columns = get(@, 'columns')
      columns = 1 if columns < 1
      ((get(@, 'contentIndex') % columns) * get(@, 'columnWidth')) + get(@, 'margin')
  })

  ###
    In pixels, the width of this listing. Typically, this value is provided
    by the `adjustedColumnWidth` property of the parent `Emberella.GridView`.

    @property columnWidth
    @type Integer
  ###
  columnWidth: computed.oneWay 'listView.adjustedColumnWidth'

  ###
    In pixels, the width of this listing.

    @property width
    @type Integer
  ###
  width: computed('margin', 'columnWidth', {
    get: ->
      get(@, 'columnWidth') - get(@, 'margin')
  })

`export default EllaGridItemComponent`
