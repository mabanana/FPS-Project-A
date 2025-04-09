extends Node3D
class_name BulletHole

func _ready():
	scale *= 0.1
	rotation.x = (randf_range(0,180))
	rotation.y = (randf_range(0,180))
	rotation.z = (randf_range(0,180))

func _process(delta):
	var tween = get_tree().create_tween()
	tween.tween_property($MeshInstance3D, "transparency", 1, 5)
	tween.tween_callback(queue_free)
