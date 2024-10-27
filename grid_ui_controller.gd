class_name GridUIController
extends GridContainer

var inv_size = 8
@export var test_tex : Texture2D

func _ready():
	columns = 4
	for i in inv_size:
		var slot = GridSlot.new()
		if i < 4:
			slot.add_item(test_tex)
			slot.hotkey_label.text = str(i+1)
		add_child(slot)
