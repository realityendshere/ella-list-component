`import Ember from 'ember'`
`import config from './config/environment'`

Router = Ember.Router.extend
  location: config.locationType

router = Router.map ->
  @route 'index', path: '/'

  @route 'list', { path: '/list' }, ->
    @route 'small'
    @route 'big'
    @route 'empty'
    @route 'sparse'

  @route 'grid', { path: '/grid' }, ->
    @route 'small'
    @route 'big'
    @route 'empty'
    @route 'sparse'

`export default router`

