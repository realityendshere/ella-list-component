`import Ember from 'ember'`
`import EllaListableMixin from 'ella-list-component/components/ella-listable'`

EllaGridComponent = Ember.Component.extend EllaListableMixin,
  ###
    Add the class name `emberella-grid`.

    @property classNames
    @type Array
    @default ['emberella-grid']
  ###
  classNames: ['emberella-grid']

`export default EllaGridComponent`
