class_name ScrollVBoxController
extends ScrollContainer

var core: CoreModel
var core_changed: Signal
var contexts

var inventory_size: int
@export var test_tex : Texture2D

var selection: int
var selection_rect: GridSelectRect
var grid_container: GridContainer

func _init():
	grid_container = GridContainer.new()
	grid_container.columns = 4
	custom_minimum_size = Vector2(256, 64)
	add_child(grid_container)

# TODO : reflect inventory in the data
func swap_data(item1, item2):
	var temp = item1.texture
	item1.texture = item2.texture
	item2.texture = temp
	_update()

func change_active_gun(index):
	core.inventory.active_gun_index = index
	core_changed.emit(contexts.gun_swap_started, null)

func bind(core: CoreModel, core_changed: Signal):
	self.core = core
	self.core_changed = core_changed
	contexts = core.services.Context
	
	core_changed.connect(_on_core_changed)
	
	selection = core.inventory.active_gun_index
	inventory_size = core.player.inventory_size
	_update()

func _on_core_changed(context, payload):
	selection = core.inventory.active_gun_index
	if context in [contexts.gun_dropped, contexts.gun_picked_up, contexts.gun_swap_started]:
		_update()

func _update():
	for child in grid_container.get_children():
		child.queue_free()
	for i in inventory_size:
		var slot = GridSlot.new()
		if i == selection:
			selection_rect = GridSelectRect.new()
			slot.add_child(selection_rect)
			slot.custom_minimum_size = Vector2(70,64)
		if i < 4: # TODO tie to weapon slots number constant
			slot.add_item(test_tex)
			slot.index = i
		slot.controller = self
		grid_container.add_child(slot)
	var selected_child = grid_container.get_child(selection)
