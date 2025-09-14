extends Control
class_name MinimapController

@onready var map_dot = preload("res://UI/map_dot.tscn")
@export var detect_dist: int

var map_size
var enemy_color = Color.CRIMSON
var mod_max: float = 1
var mod_min: float = 0.4
var fading: bool = true
var blink_interval: float = 4
var delta_mod_a: float
var dot_mod: float

func _ready():
	dot_mod = mod_max
	delta_mod_a = (mod_max - mod_min) / blink_interval * 5
	map_size = 200
	$Panel.custom_minimum_size = Vector2(map_size, map_size)
	Signals.map_updated.connect(_on_map_updated)
	
func _process(delta):
	if fading:
		dot_mod = move_toward(dot_mod, mod_min, delta_mod_a * delta)
		if dot_mod == mod_min:
			fading = false
	else:
		dot_mod = move_toward(dot_mod, mod_max, delta_mod_a * delta)
		if dot_mod == mod_max:
			fading = true
	_set_dot_mod()

# TODO: also render map navmesh underneath and clip contents
func _update(positions):
	for child in $Panel.get_children():
		if child != %ColorRect:
			child.queue_free()
	for pos in positions:
		var pos_2d = Vector2(pos.x, pos.z)
		if pos_2d.length() < detect_dist / 2:
			var new_map_dot = map_dot.instantiate()
			var map_scale = map_size / detect_dist
			new_map_dot.position += pos_2d * map_scale
			new_map_dot.color = enemy_color
			$Panel.add_child(new_map_dot)

func _on_map_updated(payload = null):
	_update(payload["positions"])

func _set_dot_mod():
	for child in $Panel.get_children():
		if child != %ColorRect:
			child.modulate.a = dot_mod
