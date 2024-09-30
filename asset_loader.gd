class_name AssetLoader
# TODO Consider combining functionality with node instancer

var scenes: Dictionary

var scene_paths: Dictionary

# TODO: phase out OID and use EntityMetadataModel.EntityType instead
func _init():
	scenes = {}
	scene_paths = {
	1001: "res://gun_on_floor.tscn",
	5001: "res://bullet_hole.tscn",
	5002: "res://damage_number.tscn",
	5003: "res://bullet_particle.tscn",
	# TODO: Use particle trail instead of mesh
	5004: "res://ray_trail_mesh.tscn",
	2001: "res://player.tscn",
	3001: "res://target_dummy.tscn",
	3002: "res://moving_box_enemy.tscn",
	}
	
func get_scene(oid):
	if !oid in scenes:
		prints(oid ,"load successful" if load_scene(oid) else "load unsuccessful")
	else:
		push_error("Scene not found")
	return scenes[oid]

func load_scene(oid):
	if oid in scene_paths:
		scenes[oid] = load(scene_paths[oid])
		return true
