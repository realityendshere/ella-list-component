`import Ember from 'ember'`
`import StyleBindingsMixin from 'ella-burn-ins/mixins/style-bindings'`
`import EllaListComponent from 'ella-list-component/components/ella-list'`

get = Ember.get
typeOf = Ember.typeOf
computed = Ember.computed

EllaListItemComponent = Ember.Component.extend StyleBindingsMixin,
  classNames: ['ella-list-item']

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

  content: computed('contentIndex', 'listView', {
    get: ->
      idx = get(@, 'contentIndex')
      listView = get(@, 'listView')
      listView
      listContent = get(listView, 'content')
      if typeOf(listContent.objectAt) is 'function'
        return listContent.objectAt(idx)
      else if typeOf(listContent) is 'array'
        listContent[idx]
      else
        null
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



  listView: computed('parentView', {
    get: ->
      @nearestOfType EllaListComponent
  })




`export default EllaListItemComponent`
