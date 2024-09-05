extends Node3D
class_name DamageNumber
@onready var label: Label3D = %Label
@export var linger_time: int
@export var rand_range_x: Vector2
@export var rand_range_y: Vector2
@export var rand_range_z: Vector2
@export var font_size: int
@export var outline_proportion: float
@export var pixel_size: float
@export var modulate: Color
var rand_position: Vector3
var damage_number: int
var damage_scale: float

func stringify(number):
	if number >= 10000000000:
		return str(number/1000000000) + "B"
	elif number >= 10000000:
		return str(number/1000000) + "M"
	elif number >= 10000:
		return str(number/1000) + "K"
	else: 
		return str(number)

func _ready():
	if not damage_number:
		damage_number = 0
	label.text = stringify(damage_number)
	label.set_modulate(modulate.lerp(Color.CRIMSON, damage_scale*damage_scale))
	label.set_billboard_mode(1)
	label.fixed_size = true
	label.double_sided = false
	label.font_size += font_size * damage_scale
	label.pixel_size = pixel_size
	label.outline_render_priority = 0
	label.outline_size = label.font_size * outline_proportion
	rand_position = Vector3(randf_range(rand_range_x.x,rand_range_x.y),
	randf_range(rand_range_y.x,rand_range_y.y),
	randf_range(rand_range_z.x,rand_range_z.y))

func _process(delta):
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", rand_position, 2)
	tween.tween_callback(queue_free)
