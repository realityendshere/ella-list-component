`import Ember from 'ember'`
`import ScrollHandlerMixin from 'ella-burn-ins/mixins/scroll-handler'`
`import ResizeHandlerMixin from 'ella-burn-ins/mixins/resize-handler'`
`import StyleBindingsMixin from 'ella-burn-ins/mixins/style-bindings'`
`import HashBindingsMixin from 'ella-burn-ins/mixins/hash-bindings'`

get = Ember.get
set = Ember.set
setProperties = Ember.setProperties
computed = Ember.computed
run = Ember.run
debounce = run.debounce
throttle = run.throttle

EllaListComponent = Ember.Component.extend ScrollHandlerMixin, ResizeHandlerMixin, StyleBindingsMixin, HashBindingsMixin,
  ###
    @property isEmberellaListComponent
    @type Boolean
    @default true
    @final
  ###
  isEmberellaListComponent: true

  ###
    Add the class name `emberella-list`.

    @property classNames
    @type Array
    @default ['emberella-list']
  ###
  classNames: ['emberella-list']

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

  hashBindings: ['yielded']

  yieldedBindings: ['rowHeight', 'totalHeight', 'visibleRows', 'indices']

  # ###
  #   Specify the component class for each item listing. This must be an instance
  #   of `EllaListItemComponent` or otherwise fully implement the content
  #   recycling and re-positioning necessary for this incremental list view to
  #   function as expected.

  #   @property itemComponentClass
  #   @type Ember.Component
  #   @default EllaListItemComponent
  # ###
  # itemComponentClass: EllaListItemComponent

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

    For example, if 10 rows are visible and `visibilityBuffer` is `0.2`,
    then 2 (10 * 0.2) bonus rows will be rendered above and below the
    "stage." This potentially allows data fetching to commence just a
    little before listings become visible.

    @property visibilityBuffer
    @type Number
    @default 0.2
  ###
  visibilityBuffer: 0.2

  ###
    The number of milliseconds to wait between geometry recalculations as
    the user resizes the browser window.

    @property resizeThrottle
    @type Integer
    @default 100
  ###
  resizeThrottle: 100

  ###
    The number of milliseconds to wait after the most recent scrolling event
    before initiating any data fetching activity.

    This only applies to data that appears stale or is not yet loaded in the
    browser.

    @property loadDelay
    @type Integer
    @default 200
  ###
  loadDelay: 200

  ###
    The number of milliseconds scrolling animations will take to complete.

    A value of 0 or less will disable scrolling animations entirely.

    @property scrollDuration
    @type Integer

  ###
  scrollDuration: 100

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

  indices: computed('startingIndex', 'visibleRows', 'content.length', {
    get: ->
      visibleRows = get(@, 'visibleRows')
      maxIdx = Math.min((visibleRows), get(@, 'content.length'))
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

  # ###
  #   Check if an object is already loaded at a specified index.

  #   @method isObjectAt
  #   @param {Integer} idx The index to check for an object
  #   @return {Boolean} Returns true if object found at index provided
  # ###
  # isObjectAt: (idx) ->
  #   content = get(@, 'content')
  #   return false unless content?
  #   if content.isObjectAt then !!(content.isObjectAt(idx))
  #   else if content.objectAtContent then !!(content.objectAtContent(idx))
  #   else !!(content.objectAt(idx))

  # ###
  #   Scroll to the specified position given in pixels.

  #   To help users follow scrolling activity, this method includes a quick
  #   animation courtesy of jQuery `animate` if available.

  #   @method scrollTo
  #   @param {Integer} scrollTop New scroll location in pixels
  #   @param {Boolean} disableAnimate Shut off animated scroll if true
  #   @chainable
  # ###
  # scrollTo: (scrollTop, disableAnimate = false) ->
  #   scrollTop = parseInt(scrollTop, 10) || 0
  #   scrollTop = Math.min(scrollTop, get(@, 'totalHeight') - get(@, 'height')) #can't scroll past last page
  #   scrollDuration = parseInt(get(@, 'scrollDuration'), 10) || 0
  #   $element = @$()
  #   if $element? and $element.stop? and $element.animate and scrollDuration > 0 and !disableAnimate
  #     $element.stop(true, true).animate({scrollTop: scrollTop}, scrollDuration)
  #   else
  #     get(@, 'element').scrollTop = scrollTop
  #     set(@, 'scrollTop', scrollTop)
  #   @

  # ###
  #   Scroll to the item at the specified index.

  #   The item can be scrolled into view with its bottom edge aligned to the
  #   bottom of the viewable area (default) or with its top edge aligned to the
  #   top of the viewable area.

  #   If the item is already fully visible, this method will have no effect.

  #   @method scrollToItem
  #   @param {Integer} idx Index of listing to scroll to
  #   @param {Boolean} alignToFirst Item scrolls to top or bottom of stage
  #   @chainable
  # ###
  # scrollToItem: (idx, alignToFirst = false) ->
  #   # If entire item is positioned in the viewable area, no scrolling needed
  #   return @ if @itemFullyVisible(idx)

  #   idx = parseInt(idx, 10) || 0
  #   contentLength = get(@, 'content.length')
  #   idx = Math.min idx, contentLength # Can't scroll past last item

  #   scrollPosition = @computeItemScrollPosition(idx)

  #   # Adjustment for aligning item to bottom of viewable area
  #   scrollPosition = scrollPosition - get(@, 'height') + get(@, 'rowHeight') unless alignToFirst
  #   @scrollTo(scrollPosition)

  # ###
  #   Scroll down or up a "page."

  #   @method scrollPage
  #   @param {Boolean} up Scroll up one "page" if true
  #   @chainable
  # ###
  # scrollPage: (up = false) ->
  #   scrollTop = get(@, 'scrollTop')
  #   height = get(@, 'height')

  #   #Don't scroll quite an entire page, that's visually confusing
  #   delta = Math.floor(height * 0.94)

  #   delta = -1 * delta if up
  #   @scrollTo(scrollTop + delta)

  # ###
  #   Scroll one "page" up

  #   @method scrollPageUp
  #   @chainable
  # ###
  # scrollPageUp: ->
  #   @scrollPage true

  # ###
  #   Scroll one "page" down

  #   @method scrollPageDown
  #   @chainable
  # ###
  # scrollPageDown: ->
  #   @scrollPage false

  # ###
  #   Scroll instantly to the top of the listing.

  #   @method scrollToTop
  #   @chainable
  # ###
  # scrollToTop: ->
  #   @scrollTo(0, true)

  # ###
  #   Scroll instantly to the end of the listing.

  #   @method scrollToBottom
  #   @chainable
  # ###
  # scrollToBottom: ->
  #   @scrollTo(get(@, 'totalHeight'), true)

  # ###
  #   Calculates the specified item's scroll position from the top of the
  #   listing. Scrolling to the result should align the top of the item with the
  #   top of the viewable area.

  #   @method computeItemScrollPosition
  #   @param {Integer} idx Index to calculate a scroll position for
  #   @return {Integer}
  # ###
  # computeItemScrollPosition: (idx) ->
  #   (parseInt(idx, 10) || 0) * get(@, 'rowHeight')

  # ###
  #   Calculates the specified item's scroll position from the top of the
  #   listing. Scrolling to the result should align the top of the item with the
  #   top of the viewable area.

  #   @method itemFullyVisible
  #   @param {Integer} idx Index to check for visibility
  #   @return {Boolean}
  # ###
  # itemFullyVisible: (idx) ->
  #   idx = parseInt(idx, 10) || 0
  #   stageTop = get(@, 'scrollTop')
  #   stageBottom = stageTop + get(@, 'height')
  #   itemTop = @computeItemScrollPosition(idx)
  #   itemBottom = itemTop + get(@, 'rowHeight')
  #   !!(itemTop >= stageTop and itemBottom <= stageBottom)

  # ###
  #   Calculates the number of list items to render.

  #   @method numberOfVisibleItems
  #   @return {Integer}
  # ###
  # numberOfVisibleItems: ->
  #   Math.min get(@, 'visibleRows'), get(@, 'content.length')

  # ###
  #   Override standard collection view behavior.

  #   @method arrayWillChange
  # ###
  # arrayWillChange: ->@

  # ###
  #   Override standard collection view behavior.

  #   @method arrayDidChange
  # ###
  # arrayDidChange: (content, start, removed, added) ->
  #   @_updateChildViews()

  # ###
  #   Adjust list view layout after being added to the DOM. Override this
  #   function to do any set up that requires an element in the document body.

  #   @event didInsertElement
  # ###
  # didInsertElement: ->
  #   @_super()
  #   @adjustLayout()

  # ###
  #   Called before destruction of the view.

  #   @method willDestroy
  # ###
  # willDestroy: ->
  #   @destroyAllChildren()
  #   @_super()

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
    setProperties(@, {
      scrolling: true
      scrollTop: evt.target.scrollTop
    })
    @_debouncedOnScroll(evt)

  # ###
  #   Called when scrolling reaches the top of the listing.

  #   @event didScrollToTop
  # ###
  # didScrollToTop: ->@

  # ###
  #   Called when scrolling reaches the end of the listing.

  #   @event didScrollToBottom
  # ###
  # didScrollToBottom: ->@

  # ###
  #   Called when the number of visible listings changes.

  #   Triggered with a single argument: the number of items this listing view
  #   will attempt to render.

  #   Useful for alerting the controller how many items should be fetched from
  #   the server.

  #   @event visibleItemsDidChange
  # ###
  # visibleItemsDidChange: ->@

  # ###
  #   @private

  #   Renders the list items and inserts an element to establish the scrolling
  #   height.

  #   @method _renderList
  # ###
  # _renderList: ->
  #   @_appendScrollingView()
  #   # Ember.run.later(@, ->
  #   #   @_updateChildViews()
  #   # , 1)

  # ###
  #   @private

  #   Resets the list rendering.

  #   @method _rerenderList
  # ###
  # _rerenderList: ->
  #   @destroyAllChildren()
  #   @_renderList()

  # ###
  #   @private

  #   Inject a really tall element into the listing to "prop it open."

  #   @method _appendScrollingView
  # ###
  # _appendScrollingView: ->
  #   scroller = get(@, 'scrollerComponent')

  #   debugger

  #   @append scroller

  # ###
  #   @private

  #   Create a really tall element that establishes the scrolling height for this
  #   listing.

  #   @method _createScrollingView
  # ###
  # _createScrollingView: ->
  #   EllaListScrollComponent.create()


  #   scrollTag = Ember.CollectionView.CONTAINER_MAP[get(@, 'tagName')]
  #   Ember.View.createWithMixins(StyleBindingsMixin,
  #     tagName: scrollTag
  #     styleBindings: ['height', 'width']
  #     heightBinding: 'parentView.totalHeight'
  #     width: 1
  #   )

  # ###
  #   @private

  #   Provide updated data and positioning to each child listing as the scroll
  #   position changes.

  #   In short: this is the listing view recycling center.

  #   @method _updateChildViews
  #   @return null
  # ###
  # _updateChildViews: Ember.observer ->
  #   return if get(@, 'isDestroyed')

  #   # Remove the view that appears when there is no content to display
  #   emptyView = get(@, 'emptyView')
  #   emptyView.removeFromParent() if emptyView and emptyView instanceof Ember.View

  #   itemViewClass = get(@, 'itemViewClass')
  #   itemViewClass = get(itemViewClass) if typeof itemViewClass is 'string'
  #   contentLength = get(@, 'content.length')
  #   childViews = @
  #   childViewsLength = Math.max(0, get(@, 'length') - 1) #account for scrollingView
  #   visibleItems = @numberOfVisibleItems()
  #   delta = visibleItems - childViewsLength
  #   startingIndex = @_startingIndex()
  #   endingIndex = startingIndex + visibleItems
  #   idxBottom = @_indexOfBottomRow() || childViewsLength

  #   if contentLength > 0
  #     unless delta is 0
  #       # Create or destroy listing views as needed to fill the visible space.
  #       # Needed for initial rendering and when the listing view changes size.
  #       for i in [0...delta]
  #         if (delta > 0)
  #           @insertAt((idxBottom + i), @createChildView(itemViewClass))
  #         else
  #           @objectAt(idxBottom + i)?.removeFromParent().destroy()
  #       childViewsLength = visibleItems

  #     # Recycle listing views
  #     for i in [startingIndex...endingIndex]
  #       childView = childViews.objectAt(i % childViewsLength)
  #       @_reuseChildForContentIndex(childView, i)

  #   else
  #     # If `emptyView` is correctly defined and the list length is 0, append
  #     # it to the listing
  #     for i in [0...childViewsLength]
  #       childView = childViews.objectAt(i)
  #       @_reuseChildForContentIndex(childView, i) if childView
  #     return unless emptyView
  #     isClass = Ember.CoreView.detect emptyView
  #     emptyView = @createChildView(emptyView)
  #     set(@, 'emptyView', emptyView)
  #     @_createdEmptyView = emptyView if isClass
  #     @unshiftObject(emptyView)

  #   null
  # , 'startingIndex'

  # ###
  #   @private

  #   Recycle a child listing with data from a specified index.

  #   If content is available at the specified index, it will be injected into
  #   the listing immediately. Otherwise, the listing will wait the number of
  #   milliseconds defined in the `loadDelay` property. If the scroll position
  #   has not changed during the delay, the list view will request the data be
  #   fetched.

  #   @method _reuseChildForContentIndex
  #   @param {Emberella.ListItemView} childView The listing to update
  #   @param {Integer} contentIndex
  #   @return null
  # ###
  # _reuseChildForContentIndex: (childView, contentIndex) ->
  #   return unless childView?
  #   return if get(childView, 'isDestroyed')

  #   currentStartingIndex = @_startingIndex()

  #   @_finalizeReuseChildForContentIndex(childView, contentIndex, true)

  #   # If an object is available to show at the provided content index, then display
  #   # it immediately. Otherwise, wait a moment and if scrolling has stopped, issue a
  #   # request for the object
  #   unless @isObjectAt(contentIndex)
  #     Ember.run.later(@, ->
  #       @_finalizeReuseChildForContentIndex(childView, contentIndex) if currentStartingIndex is @_startingIndex()
  #     , get(@, 'loadDelay'))

  #   null

  # ###
  #   @private

  #   Complete recycle process a child listing with data from a specified index.

  #   In attempting to request data from the attached controller, the list view
  #   will pass an additional `dontFetch` parameter if content should not be
  #   retrieved from the persistence layer for this listing.

  #   @method _finalizeReuseChildForContentIndex
  #   @param {Emberella.ListItemView} childView The listing to update
  #   @param {Integer} contentIndex
  #   @param {Boolean} dontFetch
  #   @return null
  # ###
  # _finalizeReuseChildForContentIndex: (childView, contentIndex, dontFetch) ->
  #   return if get(childView, 'isDestroyed')

  #   content = get @, 'content'
  #   contentLength = get @, 'content.length'
  #   currentContent = get childView, 'content'
  #   newContent = if contentIndex < contentLength then content.objectAt(contentIndex, dontFetch) else null

  #   return if currentContent is newContent

  #   childView.teardownContent(contentIndex, dontFetch) if childView?.teardownContent?
  #   set(childView, 'contentIndex', contentIndex)
  #   set(childView, 'content', newContent)
  #   childView.prepareContent(contentIndex, dontFetch) if childView?.prepareContent?

  #   null

  # ###
  #   @private

  #   Return the current `startingIndex` property.

  #   @method _startingIndex
  #   @return Integer
  # ###
  # _startingIndex: ->
  #   get(@, 'startingIndex')

  # ###
  #   @private

  #   The bottom row is the rendered listing view farthest from the top of the
  #   scrolling list.

  #   The intent of this computation is to allow new listings to be inserted
  #   below the bottom-most "visible" row and reduce the need for completely
  #   recycling every listing when new, visible items are added for any reason
  #   (e.g. new records, window resized)

  #   @method _indexOfBottomRow
  #   @return Integer
  # ###
  # _indexOfBottomRow: ->
  #   result = 0
  #   childViews = @
  #   childViewsLength = get(@, 'length') - 1
  #   previousTop = 0
  #   return result if childViewsLength <= 0
  #   for i in [0...childViewsLength]
  #     childView = childViews.objectAt(i)
  #     top = childView.get('top') ? 0
  #     if top >= previousTop
  #       result = i
  #       previousTop = top
  #     else
  #       return result
  #   result

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


  # ###
  #   @private

  #   Handle a complete change of content.

  #   @method _contentDidChange
  # ###
  # _contentDidChange: Ember.observer ->
  #   @_super()
  #   @_rerenderList() if get(@, '_state') is 'inDOM'
  # , 'content'

  # ###
  #   @private

  #   Trigger event when scroll position reaches the beginning or end.

  #   @method _scrollTopDidChange
  # ###
  # _scrollTopDidChange: Ember.observer ->
  #   scrollTop = get(@, 'scrollTop')
  #   if scrollTop <= 0
  #     @trigger('didScrollToTop')
  #   else if scrollTop >= (get(@, 'totalHeight') - get(@, 'height'))
  #     @trigger('didScrollToBottom')
  # , 'scrollTop'

  # ###
  #   @private

  #   Trigger event when the number of visible items appears to have changed.

  #   @method _visibleItemsDidChange
  # ###
  # _visibleItemsDidChange: Ember.observer ->
  #   @trigger('visibleItemsDidChange', (@numberOfVisibleItems() || 0))
  # , 'visibleRows'

  # ###
  #   @private

  #   Request list item data if shouldRequestObjects property becomes `true`
  #   on content.

  #   @method _shouldRequestObjectsDidChange
  # ###
  # _shouldRequestObjectsDidChange: Ember.observer ->
  #   @_updateChildViews() if get(@, 'content.shouldRequestObjects')
  # , 'content.shouldRequestObjects'

  # _setup: Ember.on('didInsertElement', ->
  #   run.later(@, ->
  #     @adjustLayout()
  #   , 1)
  # )

  _throttledOnResize: ->
    @_recalculateDimensions()

  _onScroll: (evt) ->
    return if get(@, 'isDestroyed') or get(@, 'isDestroying')

    setProperties(@, {
      scrolling: false
    })

  _debouncedOnScroll: (evt) ->
    debounce(@, @_onScroll, evt, 30)

`export default EllaListComponent`
