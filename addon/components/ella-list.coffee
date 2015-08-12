`import Ember from 'ember'`
`import EllaListableMixin from 'ella-list-component/components/ella-listable'`

EllaListComponent = Ember.Component.extend EllaListableMixin,
  ###
    Add the class name `emberella-list`.

    @property classNames
    @type Array
    @default ['emberella-list']
  ###
  classNames: ['emberella-list']

`export default EllaListComponent`
