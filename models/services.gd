class_name CoreServices

var id_counter

enum Context {
	none,
	gun_dropped,
	gun_picked_up,
	gun_swap_started,
	gun_shot,
	bullet_hole_added,
	map_updated,
	reload_started,
	enemy_spawned,
}

func _init() -> void:
	# Starts ID generator
	id_counter = 1

func generate_rid() -> int:
	var new_id = id_counter
	id_counter += 1
	return new_id
