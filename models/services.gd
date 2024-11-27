class_name CoreServices

var id_counter
var gui_hover
var gui_drag

enum Context {
	none,
	gun_drop_started,
	gun_pickup_started,
	gun_dropped,
	gun_picked_up,
	gun_swap_started,
	gun_swapped,
	gun_shot,
	bullet_hole_added,
	bullet_particle_added,
	map_updated,
	reload_started,
	reload_ended,
	enemy_spawned,
	damage_dealt,
	damage_taken,
	player_spawned,
	entity_died,
	health_changed,
	player_spotted,
	event_input_pressed,
	event_mouse_moved,
	event_input_released,
	ray_trail_added,
	inventory_accessed,
	drag_ended,
	drag_started,
	mouse_capture_toggled,
	spell_cast,
	spell_entity_added,
	hitbox_collided,
}

func _init() -> void:
	# Starts ID generator
	id_counter = 1

func generate_rid() -> int:
	var new_id = id_counter
	id_counter += 1
	return new_id
