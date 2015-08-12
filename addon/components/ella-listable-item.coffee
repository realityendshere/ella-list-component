`import StyleBindingsMixin from 'ella-burn-ins/mixins/style-bindings'`

get = Ember.get
typeOf = Ember.typeOf
computed = Ember.computed

EllaListableItemMixin = Ember.Mixin.create(StyleBindingsMixin, {
  listView: computed('parentView', {
    get: ->
      @nearestWithProperty 'isEmberellaListComponent'
  })

  classNameBindings: ['loading']

  styleBindings: ['height', 'width', 'position', 'top', 'display', 'pointer-events']

  height: computed.oneWay 'listView.rowHeight'

  width: '100%'

  position: 'absolute'

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

  startingIndex: computed.oneWay 'listView.startingIndex'
  visibleRows: computed.oneWay 'listView.visibleRows'
  scrolling: computed.oneWay 'listView.scrolling'

  contentIndex: computed('index', 'startingIndex', 'visibleRows', {
    get: ->
      startingIndex = get(@, 'startingIndex')
      visibleRows = get(@, 'visibleRows')
      idx = get(@, 'index')
      mod = startingIndex % visibleRows
      page = Math.floor(startingIndex/visibleRows)
      page = page + 1 if idx < mod

      (page * visibleRows) + idx
  })

})

`export default EllaListableItemMixin`
