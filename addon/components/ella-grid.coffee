`import Ember from 'ember'`
`import EllaListableMixin from 'ella-list-component/components/ella-listable'`

get = Ember.get
set = Ember.set
computed = Ember.computed

EllaGridComponent = Ember.Component.extend EllaListableMixin,
  ###
    Add the class name `emberella-grid`.

    @property classNames
    @type Array
    @default ['emberella-grid']
  ###
  classNames: ['emberella-grid']

  ###
    Specify the width of each listing.

    @property columnWidth
    @type Integer
    @default 220
  ###
  columnWidth: 220

  ###
    Specify the width of each listing.

    @property columnWidth
    @type Integer
    @default 100
  ###
  rowHeight: 100

  ###
    In pixels, specify the space to leave to the left and right of
    each listing.

    @property margin
    @type Integer
    @default 10
  ###
  margin: 10

  ###
    Computes the number of columns in the grid based on the columnWidth, the
    viewable area's width, and the margin.

    @property columns
    @type Integer
  ###
  columns: computed('columnWidth', 'margin', '_width', {
    get: ->
      width = +get(@, '_width')
      columnWidth = +get(@, 'columnWidth')
      margin = +get(@, 'margin')
      result = Math.floor(width / (columnWidth + (2 * margin)))
      result = 1 if result < 1
      result
  })

  ###
    Recalculates column width to expand columns into the available
    viewable area.

    @property adjustedColumnWidth
    @type Integer
  ###
  adjustedColumnWidth: computed('columns', '_width', {
    get: ->
      Math.floor((get(@, '_width') - +get(@, 'margin')) / get(@, 'columns'))
  })

  ###
    A computed property that indicates the height of the scrollable content.
    Typically calculated by multiplying the length of the content and the
    row height then dividing by the number of columns.

    Overrides standard `Emberella.ListView` behavior.

    @property totalHeight
    @type Integer
  ###
  totalHeight: computed('content', 'content.length', 'rowHeight', '_height', 'columns', {
    get: ->
      contentLength = parseInt(get(@, 'content.length'), 10) || 0
      Math.ceil(contentLength / get(@, 'columns')) * get(@, 'rowHeight')
  })

  ###
    A computed property that indicates the index of the row closest to the
    top of the list that is (or should be) rendered.

    Overrides standard `Emberella.ListView` behavior to account for columns.

    @property startingIndex
    @type Integer
  ###
  startingIndex: computed('scrollTop', 'rowHeight', 'additionalRows', 'columns', {
    get: ->
      idx = (Math.floor(get(@, 'scrollTop') / get(@, 'rowHeight')) - get(@, 'additionalRows')) * get(@, 'columns')
      if idx > 0 then idx else 0
  })

  ###
    Calculates the number of list items to render.

    Overrides standard `Emberella.ListView` behavior to account for columns.

    @property startingIndex
    @type Integer
  ###
  numberOfVisibleItems: computed('visibleRows', 'columns', 'content.length', {
    get: ->
      items = get(@, 'visibleRows') * get(@, 'columns')
      Math.min items, get(@, 'content.length')
  })

`export default EllaGridComponent`
