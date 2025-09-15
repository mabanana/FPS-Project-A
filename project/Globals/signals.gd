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
signal health_changed
signal player_spotted
signal event_input_pressed
signal event_mouse_moved
signal event_input_released
signal ray_trail_added
signal inventory_accessed
signal drag_ended
signal drag_started
signal mouse_capture_toggled
signal spell_cast
signal spell_entity_added
signal hitbox_collided
signal hitbox_ended
signal game_loaded
signal core_loaded

func emit_core_changed(_payload=null):
	core_changed.emit(null)

func _ready():
	gun_drop_started.connect(emit_core_changed)
	gun_pickup_started.connect(emit_core_changed)
	gun_dropped.connect(emit_core_changed)
	gun_picked_up.connect(emit_core_changed)
	gun_swap_started.connect(emit_core_changed)
	gun_swapped.connect(emit_core_changed)
	gun_shot.connect(emit_core_changed)
	bullet_hole_added.connect(emit_core_changed)
	bullet_particle_added.connect(emit_core_changed)
	map_updated.connect(emit_core_changed)
	reload_started.connect(emit_core_changed)
	reload_ended.connect(emit_core_changed)
	enemy_spawned.connect(emit_core_changed)
	damage_dealt.connect(emit_core_changed)
	damage_taken.connect(emit_core_changed)
	player_spawned.connect(emit_core_changed)
	entity_died.connect(emit_core_changed)
	health_changed.connect(emit_core_changed)
	player_spotted.connect(emit_core_changed)
	event_input_pressed.connect(emit_core_changed)
	event_mouse_moved.connect(emit_core_changed)
	event_input_released.connect(emit_core_changed)
	ray_trail_added.connect(emit_core_changed)
	inventory_accessed.connect(emit_core_changed)
	drag_ended.connect(emit_core_changed)
	drag_started.connect(emit_core_changed)
	mouse_capture_toggled.connect(emit_core_changed)
	spell_cast.connect(emit_core_changed)
	spell_entity_added.connect(emit_core_changed)
	hitbox_collided.connect(emit_core_changed)
	hitbox_ended.connect(emit_core_changed)
	game_loaded.connect(emit_core_changed)
	core_loaded.connect(emit_core_changed)
