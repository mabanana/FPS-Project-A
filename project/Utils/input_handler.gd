class_name InputHandler

var input_map

static var DEFAULT_INPUT_MAP := {
	MouseButton.MOUSE_BUTTON_LEFT : PlayerActions.FIRE,
	MouseButton.MOUSE_BUTTON_RIGHT : PlayerActions.ADS,
	MouseButton.MOUSE_BUTTON_WHEEL_UP : PlayerActions.NEXT_WEAPON,
	MouseButton.MOUSE_BUTTON_WHEEL_DOWN : PlayerActions.PREV_WEAPON,
	Key.KEY_W : PlayerActions.MOVE_FORWARD,
	Key.KEY_A : PlayerActions.MOVE_LEFT,
	Key.KEY_S : PlayerActions.MOVE_BACKWARD,
	Key.KEY_D : PlayerActions.MOVE_RIGHT,
	Key.KEY_SPACE : PlayerActions.JUMP,
	Key.KEY_SHIFT : PlayerActions.SPRINT,
	Key.KEY_CTRL : PlayerActions.CROUCH,
	Key.KEY_E : PlayerActions.INTERACT,
	Key.KEY_R : PlayerActions.RELOAD,
	Key.KEY_F : PlayerActions.ACTION_F,
	Key.KEY_G : PlayerActions.ACTION_G,
	Key.KEY_Q : PlayerActions.DROP_GUN,
	Key.KEY_TAB : PlayerActions.NEXT_WEAPON,
	Key.KEY_ESCAPE : PlayerActions.ESC_MENU,
	Key.KEY_1 : PlayerActions.SELECT_SlOT_1,
	Key.KEY_2 : PlayerActions.SELECT_SlOT_2,
	Key.KEY_3 : PlayerActions.SELECT_SlOT_3,
	Key.KEY_4 : PlayerActions.SELECT_SlOT_4,
	Key.KEY_V : PlayerActions.NEXT_WEAPON,
	Key.KEY_X : PlayerActions.PREV_WEAPON,
	Key.KEY_P : PlayerActions.TOGGLE_GUN_PREVIEW,
}

# Enum for potential player actions
enum PlayerActions {
	NEXT_WEAPON,
	PREV_WEAPON,
	MOVE_FORWARD,
	MOVE_BACKWARD,
	MOVE_LEFT,
	MOVE_RIGHT,
	JUMP,
	SPRINT,
	CROUCH,
	RELOAD,
	FIRE,
	ADS, # Aim down sights
	INTERACT,
	ACTION_F, # Spell Cast
	ACTION_G, # TBD
	MELEE,
	SELECT_SlOT_1,
	SELECT_SlOT_2,
	SELECT_SlOT_3,
	SELECT_SlOT_4,
	ESC_MENU, # Main pause menu
	GAME_MENU, # Open inventory and other in game menus
	DROP_GUN,
	TOGGLE_GUN_PREVIEW,
}
 
func _init():
	input_map = DEFAULT_INPUT_MAP
	Signals.mouse_capture_toggled.connect(_on_mouse_capture_toggled)
	
func handle_input(event: InputEvent) -> void:
	# TODO: add input uncaptured state for pause screens and inventories
	if event is InputEventMouseButton and event.button_index in input_map and Input.mouse_mode == Input.MouseMode.MOUSE_MODE_CAPTURED:
		var sig
		if event.is_pressed() and !event.is_echo():
			sig = Signals.event_input_pressed
		elif event.is_released():
			sig = Signals.event_input_released
		else:
			print("ERROR: event mouse button that is neither pressed nor released detected")
			return
		sig.emit({
				"action": input_map[event.button_index], 
				"button_index" : event.button_index
				})
	elif event is InputEventKey and event.keycode in input_map:
		var sig
		if event.is_pressed() and !event.is_echo():
			sig = Signals.event_input_pressed
		elif event.is_echo():
			# print("echo press event")
			return
		elif event.is_released():
			sig = Signals.event_input_released
		else:
			print("ERROR: event key press that is neither pressed nor released detected")
			return
		sig.emit({
			"action": input_map[event.keycode], 
			"key_code" : event.keycode
			})
	elif event is InputEventMouseMotion:
		Signals.event_mouse_moved.emit({
			"relative": event.relative
			})
	else:
		prints("InputHandler: unhandled input", event.as_text())

func _on_mouse_capture_toggled(payload=null):
	if payload["prev_mode"] == Input.MOUSE_MODE_CAPTURED:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
