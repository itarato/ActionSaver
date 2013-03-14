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

  @reloadBasePath: ->
    window.location.href = window.location.origin + window.location.pathname

class Controller
  ###
  Saving a new entry
  Query params:
    - name string Name of the event.
  ###
  @save: ->
    Recorder.getInstance().addEntry RequestUtil.queryParams.name
    RequestUtil.reloadBasePath()

  ###
  Finishing a daily session.
  ###
  @end: ->
    Recorder.getInstance().endSession()
    RequestUtil.reloadBasePath()

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
    for entry, idx in entries
      entry_next = if idx >= entries.length - 1 then null else entries[idx + 1]
      if entry.type == Entry.TYPE_NORMAL
        out = out + @formatSimpleHTML(entry, entry_next)

      if entry.type == Entry.TYPE_END
        out = out + @formatEnd()
    '<table><thead><th>Name</th><th>From</th><th>To</th><th>Interval</th></thead>' + out + '</table>'

  @formatSimpleHTML: (item, item_next) ->
    time_from = (new Date(item.time)).toLocaleTimeString()
    date_to = if item_next then new Date(item_next.time) else new Date()
    time_to = date_to.toLocaleTimeString()
    interval_seconds = date_to.getTime() - item.time
    interval_hours = Math.floor(interval_seconds / 3600000)
    interval_minutes = Math.floor((interval_seconds % 3600000) / 60000)
    interval_seconds_only = Math.floor((interval_seconds % 60000) / 1000)
    interval_text = interval_hours + 'h ' + interval_minutes + 'm ' + interval_seconds_only + 's'
    '<tr><td>' + [decodeURIComponent(item.name), time_from, time_to, interval_text].join('</td><td>') + '</td></tr>'

  @formatEnd: () ->
    '<tr><td colspan="4" class="end"></td></tr>'


class Render
  @refreshUI: ->
    entries = Recorder.getInstance().entries
    out = EntryListFormatter.format(entries)
    jQuery('#report').html out
