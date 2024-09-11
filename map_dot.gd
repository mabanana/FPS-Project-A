extends ColorRect
class_name MapDot

var mod_max: float = 1
var mod_min: float = 0.2
var fading: bool = true
var blink_interval: float = 2.5
var delta_mod_a: float

func _ready():
	modulate.a = mod_max
	delta_mod_a = (mod_max - mod_min) / blink_interval * 5

func _process(delta):
	if fading:
		modulate.a = move_toward(modulate.a, mod_min, delta_mod_a * delta)
		if modulate.a == mod_min:
			fading = false
	else:
		modulate.a = move_toward(modulate.a, mod_max, delta_mod_a * delta)
		if modulate.a == mod_max:
			fading = true
	
