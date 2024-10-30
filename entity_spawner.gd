class_name EntitySpawner
# EntitySpawner is a singleton class listens to all core change signals when entities are added/removed from MapModel.entities dictionary, and then adds/removes entity node to/from the respective scene.

# Change scene var to scene_dict if multiple scenes are active simultaneously
var scene: Node3D
var core: CoreModel
var core_changed: Signal
var contexts
# Define the list of required PackedScenes for each scene to save on storing every single PackedScene in memory.
var asset_loader: AssetLoader
var sound_manager: SoundManager

func _init(scene):
	self.scene = scene
	asset_loader = AssetLoader.new()
	sound_manager = SoundManager.new(self)

func bind(core, core_changed):
	self.core = core
	self.core_changed = core_changed
	
	core_changed.connect(_on_core_changed)
	contexts = core.services.Context
	
	sound_manager.bind(core, core_changed)

# Does not make edits to core directly, and only edits Scene on core_changed
func _on_core_changed(context: CoreServices.Context, payload):
	if context in [
		contexts.gun_dropped,
		contexts.bullet_hole_added,
		contexts.enemy_spawned,
		contexts.damage_taken,
		contexts.player_spawned,
		contexts.bullet_particle_added,
		contexts.ray_trail_added,
		]:
		_spawn_node(_get_entity_scene(payload["entity_model"]), scene, context, payload)
	elif context in [
		contexts.gun_picked_up,
		contexts.entity_died,
		]:
		_remove_node(scene.entity_hash[payload["target_rid"]])

func _spawn_node(node_scene, target_scene, spawn_context, payload):
	var new_node: Node3D
	new_node = node_scene.instantiate()
	new_node.position = payload["position"]
	if spawn_context == contexts.gun_dropped:
		new_node.linear_velocity = payload["linear_velocity"]
		new_node.angular_velocity = payload["angular_velocity"]
		new_node.gun_model = payload["gun_model"]
	elif spawn_context == contexts.enemy_spawned:
		new_node.rid = payload["rid"]
		new_node.movement_speed = payload["entity_model"].metadata.movement_speed
		new_node.vision_range = payload["entity_model"].metadata.vision_range
		new_node.bind(core, core_changed)
	elif spawn_context == contexts.player_spawned:
		new_node.rid = payload["rid"]
		new_node.movement_speed = payload["entity_model"].metadata.movement_speed
		new_node.bind(core, core_changed)
	elif spawn_context == contexts.damage_taken:
		new_node.damage_number = payload["hp_change"]
		new_node.damage_scale = payload["damage_scale"]
	elif spawn_context == contexts.bullet_particle_added:
		new_node.rotation = payload["facing"]
		new_node.emitting = true
		new_node.one_shot = true
	elif spawn_context == contexts.ray_trail_added:
		new_node.direction = payload["direction"].normalized()
		new_node.speed = 120
		new_node.distance = 60
		new_node.position = payload["position"]
	# TODO: create custom add/free that reuses previously added children
	target_scene.add_child(new_node)
	
	if payload["entity_model"].type == EntityModel.EntityType.removed:
		core.map.entities.erase(payload["rid"])
	else:
		new_node.rid = payload["rid"]
		scene.entity_hash[payload["rid"]] = new_node
	core_changed.emit(contexts.none, null)

# TODO: improve behavior for despawning node from scene
func _remove_node(node):
	if core.player.target_rid == node.rid:
		core.player.target_rid = 0
		core_changed.emit(contexts.none, null)
	core.map.entities.erase(node.rid)
	scene.entity_hash.erase(node.rid)
	node.queue_free()

func _get_entity_scene(entity: EntityModel):
	var new_scene = asset_loader.get_scene(entity.entity_type)
	return new_scene
