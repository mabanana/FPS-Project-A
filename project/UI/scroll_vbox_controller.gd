class_name ScrollVBoxController
extends ScrollContainer

var inventory_size: int
@export var test_tex : Texture2D

var selection: int
var selection_rect: GridSelectRect
var grid_container: GridContainer

func _init():
	grid_container = GridContainer.new()
	grid_container.columns = 4
	grid_container.add_theme_constant_override("h_separation", 0)
	grid_container.add_theme_constant_override("v_separation", 0)
	custom_minimum_size = Vector2(256, 64)
	add_child(grid_container)

func _ready():
	if !Core or !Core.loaded:
		await Signals.core_loaded
		pass
	selection = Core.inventory.active_gun_index
	inventory_size = Core.player.inventory_size
	_update()
	Signals.gun_dropped.connect(_update)
	Signals.gun_picked_up.connect(_update)
	Signals.gun_swap_started.connect(_update) 
	Signals.inventory_accessed.connect(_update)
	Signals.core_changed.connect(_on_core_changed)
	Signals.drag_ended.connect(_on_drag_ended)

func swap_data(item1, item2):
	var guns = Core.inventory.guns
	var index1 = item1.index
	var index2 = item2.index
	if index2 < 0:
		var temp = guns.pop_at(index1)
		guns.append(temp)
		print("%s is now at %s" %[temp, str(len(guns))])
		if index1 == selection:
			change_active_gun(len(guns) - 1)
	else:
		var temp = guns[index1]
		guns[index1] = guns[index2]
		guns[index2] = temp
		print("%s is now at index %s" %[temp, str(index2)])
		if index1 == selection:
			change_active_gun(index2)
		elif index2 == selection:
			change_active_gun(index1)
	_update()

func change_active_gun(index):
	Core.inventory.active_gun_index = index
	Signals.gun_swap_started.emit(null)

func _on_core_changed(payload=null):
	selection = Core.inventory.active_gun_index
		
func _on_drag_ended(payload = null):
		_update()
		if payload["gui_hover"] is GridSlot and payload["gui_drag"]:
			swap_data(payload["gui_drag"],payload["gui_hover"])

func _update():
	for child in grid_container.get_children():
		child.queue_free()
	for i in inventory_size:
		var slot = GridSlot.new()
		if i == selection:
			selection_rect = GridSelectRect.new()
			slot.add_child(selection_rect)
			slot.custom_minimum_size = Vector2(70,64)
		if i < len(Core.inventory.guns):
			slot.add_item(test_tex)
			slot.index = i
		slot.controller = self
		grid_container.add_child(slot)
	var selected_child = grid_container.get_child(selection)
