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


class Wraith.Controllers.TodoManager extends Wraith.Controller
  init: ->
    super()
    @list = @registerModel new Wraith.Models.List, 'list'
    @items = @list.get('items')

    @items.create { text: 'Create a TodoMVC template', completed: true }
    @items.create { text: 'Rule the web' }
    @items.create { text: 'Finish wraith' }

  itemToggle: (e) =>
    e.model.set('completed', !e.model.get('completed'))
    @updateToggleState()

  updateToggleState: =>
    $toggleAll = @$els['toggle-all']
    if @items.length() is @list.completedCount()
      $toggleAll.checked = true
    else if @list.remainingCount() isnt 0
      $toggleAll.checked = false

  itemDelete: (e) =>
    @items.remove e.model.get('_id')
    @updateToggleState()

  itemEdit: (e) => e.model.set('editing', !e.model.get('editing'))

  itemKeypress: (e) =>
    return unless e.keyCode is 13 and (val = e.currentTarget.value) isnt ''
    e.model.set('text', val)
    e.model.set('editing', false)

  toggleAll: (e) => @list.setCompleted(e.currentTarget.checked)

  inputKeypress: (e) =>
    return unless e.keyCode is 13 and (val = e.currentTarget.value) isnt ''
    @items.create { text: val }
    e.currentTarget.value = ''
    @updateToggleState()
