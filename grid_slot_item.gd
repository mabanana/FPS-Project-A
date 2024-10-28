class_name GridSlotItem
extends TextureRect

# TODO : get texture based on inventory data

func _ready():
	expand_mode = TextureRect.EXPAND_KEEP_SIZE
	stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

func _get_drag_data(at_position):
	if texture:
		set_drag_preview(make_drag_preview(at_position))
		return self

func make_drag_preview(at_position):
	var t := TextureRect.new()
	t.texture = texture
	t.modulate.a = 0.8
	t.position = Vector2(-at_position)
	var c := Control.new()
	c.add_child(t)
	
	return c
