extends Node3D
class_name BulletHole

@onready var mesh_instance = $MeshInstance3D

func _ready():
	scale *= 0.1
	rotation.x = (randf_range(0,180))
	rotation.y = (randf_range(0,180))
	rotation.z = (randf_range(0,180))
	var tween := get_tree().create_tween()
	tween.tween_property(mesh_instance.mesh.material, "albedo_color:a", 0, 5)
	tween.play()
	tween.finished.connect(queue_free)
