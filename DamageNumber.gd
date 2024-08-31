extends Node3D
class_name DamageNumber
@onready var label = %Label
@export var linger_time: int
@export var rand_range_x : Vector2
@export var rand_range_y : Vector2
@export var rand_range_z : Vector2
var rand_position : Vector3
var damage_number: int = 0


func _ready():
	label.text = str(damage_number)
	rand_position = Vector3(randf_range(rand_range_x.x,rand_range_x.y),
	randf_range(rand_range_y.x,rand_range_y.y),
	randf_range(rand_range_z.x,rand_range_z.y))

func _process(delta):
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", rand_position, 2)
	tween.tween_callback(queue_free)
