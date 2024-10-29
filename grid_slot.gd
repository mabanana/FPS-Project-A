class_name GridSlot
extends PanelContainer

var item: GridSlotItem
var hotkey_label: Label
var index: int = -1
var controller: ScrollVBoxController
var is_pressed: bool

func _init():
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	
	item = GridSlotItem.new()
	hotkey_label = Label.new()
	
	hotkey_label.set_anchors_preset(Control.PRESET_TOP_LEFT)
	hotkey_label.size_flags_vertical = Control.SIZE_FILL
	
	add_child(item)
	add_child(hotkey_label)
	
	custom_minimum_size = Vector2(64,64)
	
func _ready():
	if index >= 0:
		hotkey_label.text = str(index+1)

func _on_mouse_entered():
	controller.core.services.gui_hover = self
	if !is_pressed:
		modulate.a = 0.6
	
func _on_mouse_exited():
	controller.core.services.gui_hover = null
	if !is_pressed:
		modulate.a = 1

func _on_mouse_pressed():
	controller.core.services.gui_hover = self
	modulate.a = 0.3
	is_pressed = true

func _on_mouse_released():
	if item.texture and index >= 0:
		controller.change_active_gun(index)
		is_pressed = false

func _gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_released():
			_on_mouse_released()
		elif event.is_pressed():
			_on_mouse_pressed()

func add_item(texture):
	item.texture = texture
	
func _can_drop_data(at_position, data):
	if data is GridSlotItem:
		return true
	return false
