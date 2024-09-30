extends RigidBody3D
class_name InteractableEntity

var gun_model: GunModel
var rid: int

func on_interact():
	return gun_model

func _init():
	set_collision_layer_value(1,false)
	set_collision_layer_value(2,true)
	set_collision_mask_value(2,true)
	gravity_scale = 2.5

func _ready():
	if not gun_model:
		print("gun_model not found, freeing...")
		queue_free()
