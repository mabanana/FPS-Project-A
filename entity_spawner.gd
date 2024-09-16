class_name EntitySpawner
# EntitySpawner is a singleton class listens to all core change signals when entities are added/removed from MapModel.entities dictionary, and then adds/removes entity node to/from the respective scene.

# Change scene var to scene_dict if multiple scenes are active simultaneously
var scene: Node3D
var core: CoreModel
var core_changed: Signal
var contexts
# Define the list of required PackedScenes for each scene to save on storing every single PackedScene in memory.
var node_scenes: Dictionary

func _init(scene):
	self.scene = scene
	node_scenes = {1001: preload("res://gun_on_floor.tscn"),
	5001: preload("res://bullet_hole.tscn"),
	5002: preload("res://damage_number.tscn"),
	2001: preload("res://player.tscn"),
	3001: preload("res://target_dummy.tscn"),
	}

func bind(core, core_changed):
	self.core = core
	self.core_changed = core_changed
	
	core_changed.connect(_on_core_changed)
	contexts = core.services.Context

# Does not make edits to core directly, and only edits Scene on core_changed
func _on_core_changed(context: CoreServices.Context, payload):
	if context == contexts.gun_dropped:
		_spawn_node(_get_entity_scene(payload["entity_model"]), scene, context, payload)
	elif context == contexts.gun_picked_up:
		_remove_node(scene.entity_hash[payload["rid"]])
	elif context == contexts.bullet_hole_added:
		_spawn_node(_get_entity_scene(payload["entity_model"]), scene, context, payload)
	elif context == contexts.enemy_spawned:
		_spawn_node(_get_entity_scene(payload["entity_model"]), scene, context, payload)
	elif context == contexts.damage_dealt:
		_spawn_node(_get_entity_scene(payload["entity_model"]), scene, context, payload)
	elif context == contexts.player_spawned:
		_spawn_node(_get_entity_scene(payload["entity_model"]), scene, context, payload)

func _spawn_node(node_scene, target_scene, spawn_context, payload):
	var new_node: Node3D
	new_node = node_scene.instantiate()
	new_node.position = payload["position"]
	if spawn_context == contexts.gun_dropped:
		new_node.linear_velocity = payload["linear_velocity"]
		new_node.angular_velocity = payload["angular_velocity"]
		new_node.gun_model = payload["gun_model"]
	elif spawn_context == contexts.enemy_spawned:
		new_node.position = payload["position"]
		new_node.rid = payload["rid"]
		new_node.bind(core, core_changed)
	elif spawn_context == contexts.player_spawned:
		new_node.position = payload["position"]
		new_node.rid = payload["rid"]
		new_node.bind(core, core_changed)
	elif spawn_context == contexts.damage_dealt:
		new_node.damage_number = payload["damage_number"]
		new_node.damage_scale = payload["damage_scale"]
	
	target_scene.add_child(new_node)
	
	if payload["entity_model"].type == EntityModel.EntityType.removed:
		core.map.entities.erase(payload["rid"])
	else:
		new_node.rid = payload["rid"]
		scene.entity_hash[payload["rid"]] = new_node
	core_changed.emit(contexts.none, null)

# TODO: improve behavior for despawning node from scene
func _remove_node(node):
	scene.entity_hash.erase(node.rid)
	node.queue_free()

func _get_entity_scene(entity: EntityModel):
	prints("scene for", entity.metadata.name, "found")
	return node_scenes[entity.metadata.oid]
