App = {}

class App.ListItem extends Wraith.Model
  @field 'text', { default: '' }
  @field 'completed', { default: false }
  @field 'editing', { default: false }


class App.List extends Wraith.Model
  @hasMany App.ListItem, 'items'

  completedCount: => @get('items').all().reduce(((prev, cur) -> return prev + if cur.get('completed') then 1 else 0), 0)
  remainingCount: => @get('items').length() - @completedCount()

  setCompleted: (completed) =>
    items = @get('items').all()
    for item, i in items
      item.set('completed', completed)
    @

  removeCompleted: =>
    items = @get('items').all()
    ids = (item.get('_id') for item, i in items when item.get('completed'))
    @get('items').remove(id) for id in ids
    @


class App.TodoManager extends Wraith.Controller
  init: ->
    super()
    @list = @registerModel new App.List, 'list'
    @list.bind 'change', @updateToggleState

    @items = @list.get('items')
    @items.create { text: 'Create a TodoMVC template', completed: true }
    @items.create { text: 'Rule the web' }
    @items.create { text: 'Finish wraith' }

  updateToggleState: =>
    $toggleAll = @$els['toggle-all']
    if @items.length() is @list.completedCount()
      $toggleAll.checked = true
    else if @list.remainingCount() isnt 0
      $toggleAll.checked = false

  itemToggle: (e) => e.model.set('completed', !e.model.get('completed'))
  itemDelete: (e) => @items.remove e.model.get('_id')
  itemEdit: (e) => e.model.set('editing', !e.model.get('editing'))
  toggleAll: (e) => @list.setCompleted(e.currentTarget.checked)
  clearCompleted: (e) => @list.removeCompleted();

root = exports ? @
root.App = App
