root = exports ? @

class Wraith.Models.ListItem extends Wraith.Model
  @field 'text', { default: 'New Item' }
  @field 'completed', { default: false }
  @field 'editing', { default: false }


class Wraith.Models.List extends Wraith.Model
  @hasMany Wraith.Models.ListItem, as: 'items'

  completedCount: => @get('items').all().reduce(((prev, cur) -> return prev + if cur.get('completed') then 1 else 0), 0)
  remainingCount: => @get('items').length() - @completedCount()

  setCompleted: (completed) =>
    items = @get('items').all()
    for item, i in items
      item.set('completed', completed)
    @

  removeCompleted: =>
    items = @get('items').all()
    for item, i in items when item.get('completed')
      @get('items').remove(item.get('_id'))
    @

class Wraith.Views.TodoList extends Wraith.View


class Wraith.Controllers.TodoManager extends Wraith.Controller
  view_events: [
    { type: 'click', selector: 'button.destroy', cb: 'itemDelete' }
    { type: 'click', selector: '#todo-list input[type=checkbox]', cb: 'itemToggle' }
    { type: 'dblclick', selector: 'label', cb: 'itemEdit' }
    { type: 'keypress', selector: 'input.edit', cb: 'itemKeypress' }
    { type: 'change', selector: '#toggle-all', cb: 'toggleAll' }
    { type: 'keypress', selector: 'input#new-todo', cb: 'inputKeypress' }
  ]

  init: ->
    super()

    @registerModel 'list', new Wraith.Models.List
    list = @models['list']
    items = list.get('items')
    items.create { text: 'Create a TodoMVC template', completed: true }
    items.create { text: 'Rule the web' }
    items.create { text: 'Finish wraith' }

  getDataFromEl: (el) =>
    $view = @findViewByElement el
    id = @findIdByView $view
    list = @models['list']
    items = list.get('items')
    {items, list, id}

  itemToggle: (e) =>
    {items, list, id} = @getDataFromEl(e.currentTarget)
    item = items.findById id
    item.set('completed', !item.get('completed'))
    target = item

    if items.length() is list.completedCount()
      @$els['toggle-all'].attr('checked', true)
    else if list.remainingCount() isnt 0
      @$els['toggle-all'].attr('checked', false)
    @

  itemDelete: (e) =>
    {items, list, id} = @getDataFromEl(e.currentTarget)
    items.remove id

  itemEdit: (e) =>
    {items, list, id} = @getDataFromEl(e.currentTarget)
    item = items.findById id
    item.set('editing', !item.get('editing'))

  itemKeypress: (e) =>
    return unless e.keyCode is 13 and (val = e.currentTarget.value) isnt ''
    {items, list, id} = @getDataFromEl(e.currentTarget)
    item = items.findById id
    item.set('text', val)
    item.set('editing', false)

  toggleAll: (e) =>
    checked = e.currentTarget.checked
    list = @models['list']
    list.setCompleted(checked)
    @$els['toggle-all'].attr('checked', checked)

  inputKeypress: (e) =>
    return unless e.keyCode is 13 and (val = e.currentTarget.value) isnt ''
    {items, list, id} = @getDataFromEl(e.currentTarget)
    items.create { text: val }
    e.currentTarget.value = ''
