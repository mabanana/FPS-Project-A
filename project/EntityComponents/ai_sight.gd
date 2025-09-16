class_name AiSightController

var vision_range: float
var player_pos: Vector3
var character: CharacterBody3D
var can_see_player: bool
var eye_pos: Vector3
var ray_result: Dictionary

func _init(character, eye_pos, vision_range):
	self.character = character
	self.eye_pos = eye_pos
	self.vision_range = vision_range
	Signals.map_updated.connect(_on_map_updated)

func _on_map_updated(payload=null):
	player_pos = payload["player_eye_pos"]
	if player_pos.distance_to(character.position + eye_pos) <= vision_range:
		ray_result = cast_ray_towards_target(player_pos, vision_range)
		if ray_result and (ray_result["collider"] is PlayerEntity
		or (ray_result["collider"] is EnemyEntity and ray_result["collider"].current_state == EnemyEntity.EnemyState.chasing)):
			can_see_player = true
			Signals.player_spotted.emit({"observer_rid": character.rid, "player_pos": player_pos})

func cast_ray_towards_target(target_pos: Vector3, ray_length: int) -> Dictionary:
	var origin = character.position + eye_pos
	var cast_vector = (target_pos - origin).normalized() * ray_length
	var query = PhysicsRayQueryParameters3D.create(origin, origin + cast_vector)
	
	return character.get_world_3d().direct_space_state.intersect_ray(query)
