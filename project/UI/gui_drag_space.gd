class_name GuiDragSpace
extends ColorRect

const TRANSPARENCY = 1

func _ready():
	if !Core or !Core.loaded:
		await Signals.core_loaded
		pass
	modulate.a = 0
	var viewport_size = get_viewport_rect().size
	size = viewport_size / 1.7
	position = (viewport_size - size) / 2
	color = Color(0.203, 0.65, 0.162)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _on_mouse_entered():
	print("mouse entered drag space")
	Core.services.gui_hover = self
	if Core.services.gui_drag:
		modulate.a = TRANSPARENCY
	
func _on_mouse_exited():
	Core.services.gui_hover = null
	if Core.services.gui_drag:
		modulate.a = 0
	
func _can_drop_data(at_position, data):
	if data is GridSlotItem:
		return true
	return false

func _on_drag_ended(payload=null):
	modulate.a = 0
	if payload["gui_hover"] == self:
		Signals.mouse_capture_toggled.emit(null)
