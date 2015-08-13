`import StyleBindingsMixin from 'ella-burn-ins/mixins/style-bindings'`

get = Ember.get
typeOf = Ember.typeOf
computed = Ember.computed

EllaListableItemMixin = Ember.Mixin.create(StyleBindingsMixin, {
  listView: computed('parentView', {
    get: ->
      @nearestWithProperty 'isEmberellaListComponent'
  })

  classNameBindings: ['fluctuateListingClass', 'loading']

  styleBindings: ['height', 'width', 'position', 'top', 'display', 'pointer-events']

  height: computed.oneWay 'listView.rowHeight'

  width: '100%'

  position: 'absolute'

  ###
    Give each child listing an additional class name based on the child's
    content index.

    For example, setting this property to 2 will cause listings to alternate
    between a class containing 0 or 1. (contentIndex % 2)

    @property fluctuateListing
    @type Integer
    @default 2
  ###
  fluctuateListing: 2

  ###
    The seed for the fluctuated class name.

    For example, setting this property to `item-listing` would result in class
    names like `item-listing-0` and `item-listing-1`.

    @property fluctuateListingPrefix
    @type String
    @default 'emberella-listable-item'
  ###
  fluctuateListingPrefix: 'emberella-listable-item'

  top: computed('contentIndex', 'height', {
    get: ->
      get(@, 'contentIndex') * get(@, 'height')
  })

  display: computed('content', {
    get: ->
      if get(@, 'content')? then null else 'none'
  })

  'pointer-events': computed('scrolling', {
    get: ->
      if get(@, 'scrolling') then 'none' else null
  })

  content: computed('contentIndex', 'listView', 'scrolling', {
    get: ->
      idx = get(@, 'contentIndex')
      listView = get(@, 'listView')
      Ember.assert('ella-list-item and ella-grid-item must be contained by an ella-list or ella-grid', listView?)
      listContent = get(listView, 'content')

      # Defer data fetch until scrolling slows/stops
      # This is applicable only if the content is sparse
      if (get(listContent, 'isSparseArray'))
        listContent.objectAt(idx, get(@, 'scrolling'))
      else if typeOf(listContent.objectAt) is 'function'
        listContent.objectAt(idx)
      else if typeOf(listContent) is 'array'
        listContent[idx]
      else
        null
  })

  loading: computed('content', 'content.isLoading', 'content.is_loading', {
    get: ->
      return true unless get(@, 'content')?
      get(@, 'content.isLoading') || get(@, 'content.is_loading')
  })

  ###
    Additional class name for this listing.

    @property fluctuateListingClass
    @type String
  ###
  fluctuateListingClass: computed('contentIndex', 'fluctuateListing', 'fluctuateListingPrefix', {
    get: ->
      contentIndex = get @, 'contentIndex'
      fluctuateListing = parseInt get(@, 'fluctuateListing'), 10
      fluctuateListingPrefix = get @, 'fluctuateListingPrefix'
      return '' unless fluctuateListing and fluctuateListing > 0
      [fluctuateListingPrefix, (contentIndex % fluctuateListing)].join('-')
  })

  startingIndex: computed.oneWay 'listView.startingIndex'
  numberOfVisibleItems: computed.oneWay 'listView.numberOfVisibleItems'
  scrolling: computed.oneWay 'listView.scrolling'

  contentIndex: computed('index', 'startingIndex', 'numberOfVisibleItems', {
    get: ->
      startingIndex = get(@, 'startingIndex')
      numberOfVisibleItems = get(@, 'numberOfVisibleItems')
      idx = get(@, 'index')
      mod = startingIndex % numberOfVisibleItems
      page = Math.floor(startingIndex/numberOfVisibleItems)
      page = page + 1 if idx < mod

      (page * numberOfVisibleItems) + idx
  })

})

`export default EllaListableItemMixin`
