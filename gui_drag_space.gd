class_name GuiDragSpace
extends ColorRect

var core: CoreModel
var core_changed: Signal
var contexts

var controller
const TRANSPARENCY = 1

func _init():
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _ready():
	controller = get_parent()
	modulate.a = 0
	prints(controller, get_viewport_rect().size / 2)
	var viewport_size = get_viewport_rect().size
	size = viewport_size / 1.7
	position = (viewport_size - size) / 2
	color = Color(0.203, 0.65, 0.162)

func _on_mouse_entered():
	print("mouse entered drag space")
	controller.core.services.gui_hover = self
	if controller.core.services.gui_drag:
		modulate.a = TRANSPARENCY
	
func _on_mouse_exited():
	controller.core.services.gui_hover = null
	if controller.core.services.gui_drag:
		modulate.a = 0
	
func _can_drop_data(at_position, data):
	if data is GridSlotItem:
		return true
	return false

func bind(core: CoreModel, core_changed: Signal):
	self.core = core
	self.core_changed = core_changed
	contexts = core.services.Context
	
	core_changed.connect(_on_core_changed)

func _on_core_changed(context, payload):
	if context == contexts.drag_ended:
		modulate.a = 0
		if payload["gui_hover"] == self:
			core_changed.emit(contexts.mouse_capture_toggled, null)
