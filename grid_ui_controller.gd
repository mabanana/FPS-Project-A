class_name GridUIController
extends GridContainer

var inv_size = 16
@export var test_tex : Texture2D

func _ready():
	columns = 4
	for i in inv_size:
		var slot = GridSlot.new()
		if i < 7:
			slot.add_item(test_tex)
		add_child(slot)
