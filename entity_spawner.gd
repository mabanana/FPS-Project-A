class_name EntitySpawner
# EntitySpawner is a singleton class listens to all core change signals when entities are added/removed from MapModel.entities dictionary, and then adds/removes entity node to/from the respective scene.

# Change scene var to scene_dict if multiple scenes are active simultaneously
var scene: Node3D
var core: CoreModel
var core_changed: Signal
var contexts
# Define the list of required PackedScenes for each scene to save on storing every single PackedScene in memory.
var node_scenes: Dictionary

enum SpawnContext {
	gun_dropped
}

func _init(scene):
	self.scene = scene
	node_scenes = {1001: preload("res://gun_on_floor.tscn"),
	5001: preload("res://bullet_hole.tscn")}

func bind(core, core_changed):
	self.core = core
	self.core_changed = core_changed
	
	core_changed.connect(_on_core_changed)
	contexts = core.services.Context

# Does not make edits to core directly, and only edits Scene on core_changed
func _on_core_changed(context: CoreServices.Context, payload):
	if context == contexts.gun_dropped:
		_spawn_node(_get_entity_scene(payload["entity_model"]), scene, SpawnContext.gun_dropped, payload)
	elif context == contexts.gun_picked_up:
		_remove_node(scene.entity_hash[payload["id"]])

func _spawn_node(node_scene, target_scene, spawn_context, payload, tracked = true):
	var new_node: Node3D
	if spawn_context == SpawnContext.gun_dropped:
		new_node = node_scene.instantiate()
		new_node.position = payload["position"]
		new_node.linear_velocity = payload["linear_velocity"]
		new_node.angular_velocity = payload["angular_velocity"]
		new_node.gun_model = payload["gun_model"]
		new_node.id = payload["id"]
	scene.add_child(new_node)
	if tracked:
		scene.entity_hash[payload["id"]] = new_node
	else:
		core.map.entities[payload["id"]].erase()
	core_changed.emit(contexts.none, null)

# TODO: improve behavior for despawning node from scene
func _remove_node(node):
	scene.entity_hash.erase(node.id)
	node.queue_free()

func _get_entity_scene(entity: EntityModel):
	return node_scenes[entity.metadata.oid]
