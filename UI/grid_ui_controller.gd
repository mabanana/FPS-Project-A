# Deprecated
class_name GridUIController 
extends GridContainer



var inv_size = 8
@export var test_tex : Texture2D
var selection = 0
var selection_rect: GridSelectRect

func _ready():
	for child in get_children():
		child.queue_free()
	columns = 4
	for i in inv_size:
		var slot = GridSlot.new()
		if i == selection:
			selection_rect = GridSelectRect.new()
			slot.add_child(selection_rect)
		if i < 4:
			slot.add_item(test_tex)
			slot.index = i
		add_child(slot)
	var selected_child = get_child(selection)

func change_selection(new_select: int):
	selection = new_select
	selection_rect.queue_free()
	selection_rect = GridSelectRect.new()
	get_child(selection).add_child(selection_rect)

func swap_data(item1, item2):
	var temp = item1.texture
	item1.texture = item2.texture
	item2.texture = temp
