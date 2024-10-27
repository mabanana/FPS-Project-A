class_name GridSlot
extends PanelContainer

var item: GridSlotItem
var hotkey_label: Label

func _init():
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	item = GridSlotItem.new()
	hotkey_label = Label.new()
	hotkey_label.set_anchors_preset(Control.PRESET_TOP_LEFT)
	hotkey_label.size_flags_vertical = Control.SIZE_FILL
	add_child(item)
	add_child(hotkey_label)
	
func _ready():
	custom_minimum_size = Vector2(64,64)

func _on_mouse_entered():
	modulate.a = 0.6
	
func _on_mouse_exited():
	modulate.a = 1

func _on_mouse_clicked():
	prints("clicked", name)

func _gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_on_mouse_clicked()
		pass

func add_item(texture):
	item.texture = texture
	
func _can_drop_data(at_position, data):
	if data is GridSlotItem:
		return true
	return false

func _drop_data(at_position, data):
	if data is TextureRect:
		var temp = data.texture
		data.texture = item.texture
		item.texture = temp
