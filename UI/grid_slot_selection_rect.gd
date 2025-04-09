class_name GridSelectRect
extends ColorRect

var shader_time: float = 0.0
var shader_frequency: float = 1
var shader_max_time: float = 2

func _ready():
	material = load("res://UI/GridSelectionMaterial.tres")
	color = Color(1, 0.757, 0.369)
	set_mouse_filter(MouseFilter.MOUSE_FILTER_IGNORE)

func _process(delta):
	shader_time += shader_frequency / shader_max_time * delta
	if shader_time >= 2.0:
		shader_time = 0
	material.set_shader_parameter("Parameter_Time", shader_time)
