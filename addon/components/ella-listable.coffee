`import Ember from 'ember'`
`import ScrollHandlerMixin from 'ella-burn-ins/mixins/scroll-handler'`
`import ResizeHandlerMixin from 'ella-burn-ins/mixins/resize-handler'`
`import StyleBindingsMixin from 'ella-burn-ins/mixins/style-bindings'`

get = Ember.get
set = Ember.set
setProperties = Ember.setProperties
computed = Ember.computed
run = Ember.run
debounce = run.debounce
throttle = run.throttle

EllaListableMixin = Ember.Mixin.create(ScrollHandlerMixin, ResizeHandlerMixin, StyleBindingsMixin, {
  ###
    @property isEmberellaListComponent
    @type Boolean
    @default true
    @final
  ###
  isEmberellaListComponent: true

  ###
    Add the class name `loading` when content is loading.

    @property classNameBindings
    @type Array
    @default ['loading']
  ###
  classNameBindings: ['loading']

  ###
    Properties to assemble into a dynamically computed style attribute.

    @property styleBindings
    @type Array
  ###
  styleBindings: [
    'position'
    'width'
    'height'
    'overflow'
    '-webkit-overflow-scrolling'
  ]

  ###
    Current scrolling state. True while scroll top is changing,
    false otherwise.

    @property scrolling
    @type Boolean
    @default false
  ###
  scrolling: false

  ###
    The current scroll position of the list.

    @property scrollTop
    @type Integer
    @default 0
  ###
  scrollTop: 0

  ###
    The height in pixels of each list item.

    @property rowHeight
    @type Integer
    @default 50
  ###
  rowHeight: 50

  ###
    A multiplier to calculate the number of extra rows to render above and
    below the portion of the list currently visible to the user.

    For example, if 10 rows are visible and `visibilityBuffer` is `0.1`,
    then 2 (10 * 0.1) bonus rows will be rendered above and below the
    "stage." This potentially allows data fetching to commence just a
    little before listings become visible.

    @property visibilityBuffer
    @type Number
    @default 0.1
  ###
  visibilityBuffer: 0.1

  ###
    The number of milliseconds to wait between geometry recalculations as
    the user resizes the browser window.

    @property resizeThrottle
    @type Integer
    @default 100
  ###
  resizeThrottle: 100

  ###
    The `position` style of this listing.

    @property position
    @type String
    @default 'absolute'
  ###
  position: 'absolute'

  ###
    The `width` style of this listing.

    @property width
    @type {String|Integer}
    @default '100%'
  ###
  width: '100%'

  ###
    The `height` style of this listing.

    @property height
    @type {String|Integer}
    @default '100%'
  ###
  height: '100%'

  ###
    The `overflow` style of this listing.

    @property overflow
    @type String
    @default 'auto'
  ###
  overflow: 'auto'

  ###
    The `-webkit-overflow-scrolling` style of this listing.

    @property -webkit-overflow-scrolling
    @type String
    @default 'touch'
  ###
  '-webkit-overflow-scrolling': 'touch'

  ###
    True if content `isLoading`.

    @property loading
    @type Boolean
  ###
  loading: computed.oneWay 'content.isLoading'

  ###
    A computed property that indicates the height of the scrollable content.
    Typically calculated by multiplying the length of the content and the
    row height.

    @property totalHeight
  ###
  totalHeight: computed('content', 'content.length', 'rowHeight', {
    get: ->
      contentLength = parseInt(get(@, 'content.length'), 10) || 0
      totalHeight = contentLength * get(@, 'rowHeight')
      totalHeight
  })

  ###
    A computed property that indicates the index of the row closest to the
    top of the list that is (or should be) rendered.

    @property startingIndex
    @type Integer
  ###
  startingIndex: computed('scrollTop', 'rowHeight', 'additionalRows', {
    get: ->
      idx = Math.floor(get(@, 'scrollTop') / get(@, 'rowHeight')) - get(@, 'additionalRows')
      if idx > 0 then idx else 0
  })

  ###
    An array the `{{#each}}` helper can use to render only the number of
    list items visible in the browser.

    @property indices
    @type Array
  ###
  indices: computed('startingIndex', 'numberOfVisibleItems', {
    get: ->
      maxIdx = Math.min((get(@, 'numberOfVisibleItems')), get(@, 'content.length'))
      [0...maxIdx]
  })

  ###
    A computed property that indicates the number of rows that should be
    currently visible to the user. One additional row will always be
    added to ensure row views aren't recycled until they've moved offstage.

    @property rows
  ###
  rows: computed('_height', 'rowHeight', 'totalHeight', {
    get: ->
      rowCount = get(@, '_height') / get(@, 'rowHeight')
      Math.ceil(rowCount) + 1
  })

  ###
    A computed property that indicates the number of extra rows to render above
    and below the stage.

    @property additionalRows
  ###
  additionalRows: computed('rows', 'visibilityBuffer', {
    get: ->
      Math.ceil(get(@, 'rows') * get(@, 'visibilityBuffer'))
  })

  ###
    A computed property that indicates the number of rows to render.

    @property visibleRows
  ###
  visibleRows: computed('rows', 'additionalRows', {
    get: ->
      +get(@, 'rows') + (2 * get(@, 'additionalRows'))
  })

  numberOfVisibleItems: computed('visibleRows', 'content.length', {
    get: ->
      Math.min get(@, 'visibleRows'), get(@, 'content.length')
  })

  _height: computed({
    get: ->
      if get(@, '_state') is 'inDOM' then +@$().height() else window.innerHeight
  }).volatile()

  _width: computed({
    get: ->
      if get(@, '_state') is 'inDOM' then +@$().width() else window.innerWidth
  }).volatile()

  adjustLayout: ->
    throttle(@, @_throttledOnResize, get(@, 'resizeThrottle'))

  ###
    Adjust list view layout after window resized.

    @event onResize
  ###
  onResize: (e) -> @adjustLayout()

  ###
    Update scrollTop property with value reported by the DOM event.

    @event onScroll
  ###
  onScroll: (evt) ->
    lastScrollTop = get(@, 'scrollTop')
    height = get(@, '_height')
    delta = Math.abs(evt.target.scrollTop - lastScrollTop)

    setProperties(@, {
      scrolling: true
      scrollTop: evt.target.scrollTop
    })

    if delta < height * 0.5
      @_onScroll evt
    else
      @_debouncedOnScroll(evt)

  ###
    @private

    Update both the height and width properties of this view based on its
    current state in the DOM.

    @method _recalculateDimensions
  ###
  _recalculateDimensions: ->
    @_recalculateWidth()
    @_recalculateHeight()

  ###
    @private

    Update the width property of this view based on its current state in
    the DOM.

    @method _recalculateWidth
  ###
  _recalculateWidth: ->
    return if get(@, 'isDestroyed') or get(@, 'isDestroying')
    @notifyPropertyChange '_width'
    # @set('_width', if get(@, '_state') is 'inDOM' then +@$().width() else window.innerWidth)

  ###
    @private

    Update the height property of this view based on its current state in
    the DOM.

    @method _recalculateHeight
  ###
  _recalculateHeight: ->
    return if get(@, 'isDestroyed') or get(@, 'isDestroying')
    @notifyPropertyChange '_height'
    # @set('_height', if get(@, '_state') is 'inDOM' then +@$().height() else window.innerHeight)

  _throttledOnResize: ->
    @_recalculateDimensions()

  _onScroll: (evt) ->
    return if get(@, 'isDestroyed') or get(@, 'isDestroying')

    setProperties(@, {
      scrolling: false
    })

  _debouncedOnScroll: (evt) ->
    debounce(@, @_onScroll, evt, 100)

})

`export default EllaListableMixin`
