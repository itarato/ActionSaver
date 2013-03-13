jQuery ->
  Storage.init()
  RequestUtil.init()
  RequestUtil.execute()
  Render.refreshUI()

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
  ###
  Saving a new entry
  Query params:
    - name string Name of the event.
  ###
  @save: ->
    Recorder.getInstance().addEntry RequestUtil.queryParams.name

  ###
  Finishing a daily session.
  ###
  @end: ->
    Recorder.getInstance().end()

  ###
  Resetting the session queue.
  ###
  @reset: ->
    Recorder.getInstance().reset()


class Recorder
  entries: []
  @instance

  constructor: ->
    @entries = Storage.get('entry_records', [])

  addEntry: (name) ->
    @entries.push {
      name: name,
      time: (new Date()).getTime()
      type: Entry.TYPE_NORMAL
                  }
    Storage.set 'entry_records', @entries

  endSession: () ->
    @entries.push {
      time: (new Date()).getTime()
      type: Entry.TYPE_END,
                  }
    Storage.set 'entry_records', @entries

  reset: () ->
    @entries = []
    Storage.delete('entry_records')

  entryList: () ->
    @entries

  @getInstance: () ->
    @instance || new Recorder()


class Entry
  @TYPE_NORMAL: 0x01
  @TYPE_END: 0x02


class Storage
  @storage: null

  @init: () ->
    if !window.localStorage.hasOwnProperty 'actionSaver'
      @storage = {}
    else
      @storage = JSON.parse window.localStorage.actionSaver

  @sync: () ->
    json_val = JSON.stringify(@storage)
    window.localStorage.actionSaver = json_val

  @get: (key, default_value) ->
    @storage[key] || default_value

  @set: (key, value) ->
    @storage[key] = value
    @sync()

  @delete: (key) ->
    delete @storage[key]
    @sync()


class EntryListFormatter
  @format: (entries) ->
    out = ''
    for entry in entries
      if entry.type == Entry.TYPE_NORMAL
        out = out + @formatSimpleHTML(entry)

      if entry.type == Entry.TYPE_END
        null
        # @todo to be continued

  @formatSimpleHTML: (item) ->
    '<div>' + item.name + '</div>'


class Render
  @refreshUI: ->
    entries = Recorder.getInstance().entries
    out = EntryListFormatter.format(entries)
    jQuery('#report').html out
