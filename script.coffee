jQuery ->
  RequestUtil.init()
  RequestUtil.execute()


class RequestUtil
  @queryParams: {}

  @init: ->
    search_items = window.location.search.replace(/\?/, '').split('&')
    save_param = (object, mixed_value) ->
      parts = mixed_value.split '='
      object[parts[0]] = parts[1]
    save_param @queryParams, item for item in search_items

  @execute: ->
    Controller[@queryParams.action]() if @queryParams.hasOwnProperty('action') && Controller.hasOwnProperty(@queryParams.action)

class Controller
  @save: ->


  @start: ->


class Recorder
  constructor: ->

    stored = window.localStorage.a


class Entry
  constructor: (@title, $time) ->


class Storage
  @storage: null

  @init: () ->
    @storage = window.localStorage.actionSaver || {} if @storage == null

  @sync: () ->
    window.localStorage.actionSaver = @storage

  @get: (key) ->
    @storage[key] || {}