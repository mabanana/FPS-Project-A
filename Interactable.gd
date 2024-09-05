extends RigidBody3D
class_name InteractableEntity

var gun_model: GunModel
var id: int

func on_interact():
	queue_free()
	return gun_model

func _init():
	set_collision_layer_value(1,false)
	set_collision_layer_value(2,true)
	set_collision_mask_value(2,true)
	mass = 3
	gravity_scale = 2.5

func _ready():
	if not gun_model:
		queue_free()
