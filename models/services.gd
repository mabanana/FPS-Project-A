class_name CoreServices

var id_counter

enum Context {
	none,
	gun_dropped,
	gun_picked_up,
	gun_shot
}

func _init() -> void:
	# Starts ID generator
	id_counter = 1

func generate_id() -> int:
	var new_id = id_counter
	id_counter += 1
	return new_id
