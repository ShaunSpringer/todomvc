root = exports ? @

class Wraith.Models.ListItem extends Wraith.Model
  @field 'text', { default: 'New Item' }
  @field 'completed', { default: false }
  @field 'editing', { default: false }


class Wraith.Models.List extends Wraith.Model
  @hasMany Wraith.Models.ListItem, as: 'items'

  completedCount: => @get('items').all().reduce(((prev, cur) -> return prev + if cur.get('completed') then 1 else 0), 0)
  remainingCount: => @get('items').length - @completedCount()

  setCompleted: (completed) =>
    items = @get('items').all()
    for item, i in items
      item.set('completed', completed)

  removeCompleted: =>
    items = @get('items').all()
    for item, i in items when item.get('completed')
      @get('items').remove(item.get('_id'))


class Wraith.Controllers.Main extends Wraith.Controller
  view: 'ListItem'

  init: ->
    super()
    @list = new Wraith.Models.List
    @list.bind 'add:items', @add
    @list.bind 'remove:items', @remove

    items = @list.get('items')
    items.create { text: 'Create a TodoMVC template', completed: true }
    items.create { text: 'Rule the web' }
    items.create { text: 'Finish wraith' }

    @bind 'ui:click:button.destroy', @itemDelete
    @bind 'ui:click:input[type=checkbox]', @itemToggle
    @bind 'ui:dblclick:label', @itemEdit
    @bind 'ui:keypress:input.edit', @itemKeypress
    @bind 'ui:change:input#toggle-all', @toggleAll
    @bind 'ui:keypress:input#new-todo', @inputKeypress

  itemToggle: (e) =>
    id = @findByEl e.currentTarget
    item = @list.get('items').findById id
    item.set('completed', e.currentTarget.checked)

  itemDelete: (e) =>
    id = @findByEl e.currentTarget
    item = @list.get('items').findById id
    @list.get('items').remove id

  itemEdit: (e) =>
    id = @findByEl e.currentTarget
    item = @list.get('items').findById id
    item.set('editing', !item.get('editing'))

  itemKeypress: (e) =>
    return unless e.keyCode is 13 and (val = e.currentTarget.value) isnt ''
    id = @findByEl e.currentTarget
    item = @list.get('items').findById id
    item.set('text', val)
    item.set('editing', false)

  toggleAll: (e) =>
    debugger;

  inputKeypress: (e) =>
    return unless e.keyCode is 13 and (val = e.currentTarget.value) isnt ''
    @list.get('items').create { text: val, selected: false }
    e.currentTarget.value = ''
