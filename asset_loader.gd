class_name AssetLoader
# TODO Consider combining functionality with node instancer

var scenes: Dictionary

var scene_paths: Dictionary

func _init():
	scenes = {}
	scene_paths = {
	EntityMetadataModel.EntityType.GUN_ON_FLOOR: "res://gun_on_floor.tscn",
	EntityMetadataModel.EntityType.BULLET_HOLE: "res://bullet_hole.tscn",
	EntityMetadataModel.EntityType.DAMAGE_NUMBER: "res://damage_number.tscn",
	EntityMetadataModel.EntityType.BULLET_PARTICLE: "res://bullet_particle.tscn",
	# TODO: Use particle trail instead of mesh
	EntityMetadataModel.EntityType.RAY_TRAIL: "res://ray_trail_mesh.tscn",
	EntityMetadataModel.EntityType.PLAYER: "res://player.tscn",
	EntityMetadataModel.EntityType.TARGET_DUMMY: "res://target_dummy.tscn",
	EntityMetadataModel.EntityType.MOVING_BOX: "res://moving_box_enemy.tscn",
	EntityMetadataModel.EntityType.FIRE_BALL: "res://fireball_mesh.tscn",
	}
	
func get_scene(entity_type: EntityMetadataModel.EntityType):
	if !entity_type in scenes:
		prints(EntityMetadataModel.EntityType.find_key(entity_type) ,"load successful" if load_scene(entity_type) else "load unsuccessful")
	else:
		push_error("Scene not found")
	return scenes[entity_type]

func load_scene(entity_type):
	if entity_type in scene_paths:
		scenes[entity_type] = load(scene_paths[entity_type])
		return true
