extends Node

signal core_changed
signal gun_drop_started
signal gun_pickup_started
signal gun_dropped
signal gun_picked_up
signal gun_swap_started
signal gun_swapped
signal gun_spawned
signal gun_shot
signal item_dropped
signal bullet_hole_added
signal bullet_particle_added
signal map_updated
signal reload_started
signal reload_ended
signal enemy_spawned
signal damage_dealt
signal damage_taken
signal player_spawned
signal entity_died
signal entity_freed
signal health_changed
signal player_spotted
signal event_input_pressed
signal event_mouse_moved
signal event_input_released
signal bullet_trail_added
signal inventory_accessed
signal drag_ended
signal drag_started
signal mouse_capture_toggled
signal spell_cast
signal spell_entity_added
signal spell_node_spawned
signal hitbox_collided
signal hitbox_ended
signal game_loaded
signal core_loaded

func emit_core_changed(_payload=null):
	core_changed.emit(null)

func _ready():
	for sig in get_signal_list():
		if sig["name"] and sig["name"] != "core_changed":
			connect(sig["name"], emit_core_changed)
	
