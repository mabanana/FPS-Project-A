extends Node2D

@export var start_button: Button
var scene: GameScene

# Called when the node enters the scene tree for the first time.
func _ready():
	start_button.pressed.connect(start_game)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func start_game():
	scene = load("res://GameObjects/scene1.tscn").instantiate()
	add_child(scene)
	start_button.hide()
