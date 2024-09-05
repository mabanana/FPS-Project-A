extends RigidBody3D
class_name Interactable

var gun_model: GunModel

func on_interact():
	queue_free()
	return gun_model

func _init():
	set_collision_layer_value(1,false)
	set_collision_layer_value(2,true)
	set_collision_mask_value(2,true)

func _ready():
	if not gun_model:
		queue_free()
