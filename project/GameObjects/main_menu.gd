extends Node2D

@export var start_button: Button
var scene: GameScene

# Called when the node enters the scene tree for the first time.
func _ready():
	start_button.pressed.connect(start_game)
	Signals.event_input_pressed.connect(pause_game)
	Signals.mouse_capture_toggled.connect(_on_mouse_capture_toggled)

func start_game():
	scene = load("res://GameObjects/scene1.tscn").instantiate()
	add_child(scene)
	start_button.hide()

func pause_game(payload=null):
	if payload["action"] == InputHandler.PlayerActions.ESC_MENU:
		if scene.process_mode == Node.PROCESS_MODE_INHERIT:
			scene.process_mode = Node.PROCESS_MODE_DISABLED
		else:
			scene.process_mode = Node.PROCESS_MODE_INHERIT

func _on_mouse_capture_toggled(payload=null):
	if payload["prev_mode"] == Input.MOUSE_MODE_CAPTURED:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _input(event):
	InputHandler.handle_input(event)
