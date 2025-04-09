class_name GridSelectRect
extends ColorRect

func _ready():
	material = load("res://UI/GridSelectionMaterial.tres")
	color = Color(1, 0.757, 0.369)
	set_mouse_filter(MouseFilter.MOUSE_FILTER_IGNORE)
