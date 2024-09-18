class_name AiSightController

var vision_range: float
var player_pos: Vector3
var character: CharacterBody3D
var can_see_player: bool
var eye_pos: Vector3

var core: CoreModel
var core_changed
var contexts

func bind(core, core_changed):
	self.core = core
	self.core_changed = core_changed
	contexts = core.services.Context
	core_changed.connect(_on_core_changed)

func _init(character, eye_pos, vision_range):
	self.character = character
	self.eye_pos = eye_pos
	self.vision_range = vision_range

func _on_core_changed(context, payload):
	if context == contexts.map_updated:
		player_pos = payload["player_pos"]
		var ray_result = cast_ray_towards_target(player_pos, vision_range)
		if ray_result and ray_result.collider is PlayerEntity:
			can_see_player = true
			core_changed.emit(contexts.player_spotted, {"observer_rid": character.rid, "player_pos": player_pos})

func cast_ray_towards_target(target_pos: Vector3, ray_length: int) -> Dictionary:
	var origin = character.position + eye_pos
	var cast_vector = (target_pos - origin).normalized() * ray_length
	var query = PhysicsRayQueryParameters3D.create(origin, origin + cast_vector)
	return character.get_world_3d().direct_space_state.intersect_ray(query)
