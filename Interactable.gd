extends RigidBody3D
class_name InteractableEntity

var gun_model: GunModel
var mesh_instance: MeshInstance3D
var collision_shape: CollisionShape3D
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
	mesh_instance = $MeshInstance3D
	collision_shape = $CollisionShape3D
	# TODO: pass in gun mesh from entity spawner
	match gun_model.type:
		GunMetadataModel.GunType.TEST_GUN_A:
			mesh_instance.mesh = load("res://Ninja Adventure - Asset Pack/Models/test_smg.obj")
		GunMetadataModel.GunType.TEST_GUN_B:
			mesh_instance.mesh = load("res://Ninja Adventure - Asset Pack/Models/test_pistol.obj")
		GunMetadataModel.GunType.TEST_GUN_C:
			mesh_instance.mesh = load("res://Ninja Adventure - Asset Pack/Models/test_shotgun.obj")
		GunMetadataModel.GunType.TEST_GUN_D:
			mesh_instance.mesh = load("res://Ninja Adventure - Asset Pack/Models/test_sniper.obj")
		GunMetadataModel.GunType.RARE_GUN_A:
			mesh_instance.mesh = load("res://Ninja Adventure - Asset Pack/Models/bullet_sprinkler.obj")
		_:
			mesh_instance.mesh = load("res://Ninja Adventure - Asset Pack/Models/test_shotgun.obj")
	collision_shape.make_convex_from_siblings()
