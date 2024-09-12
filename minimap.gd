extends Control
class_name MinimapController

var core
var core_changed
@onready var map_dot = preload("res://map_dot.tscn")
var map_size
var contexts
var max_map_dist

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
	max_map_dist = 20
	$Panel.custom_minimum_size = Vector2(map_size, map_size)
	
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

func _update(positions):
	for pos in positions:
		for child in $Panel.get_children():
			if child != %ColorRect:
				child.queue_free()
		var pos_2d = Vector2(pos.x, pos.z)
		if pos_2d.length() < max_map_dist / 2:
			var new_map_dot = map_dot.instantiate()
			var map_scale = map_size / max_map_dist
			new_map_dot.position += pos_2d * map_scale
			new_map_dot.color = enemy_color
			$Panel.add_child(new_map_dot)
			
func bind(core: CoreModel, core_changed: Signal):
	self.core = core
	self.core_changed = core_changed
	contexts = core.services.Context
	
	core_changed.connect(_on_core_changed)
	
func _on_core_changed(context, payload):
	if context == contexts.map_updated:
		_update(payload["positions"])

func _set_dot_mod():
	for child in $Panel.get_children():
		if child != %ColorRect:
			child.modulate.a = dot_mod