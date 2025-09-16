extends Node
class_name EntitySpawner
# EntitySpawner is a singleton class listens to all Core change signals when entities are added/removed from MapModel.entities dictionary, and then adds/removes entity node to/from the respective scene.

# Change scene var to scene_dict if multiple scenes are active simultaneously
var scene: GameScene

# Define the list of required PackedScenes for each scene to save on storing every single PackedScene in memory.
var asset_loader: AssetLoader
var sound_manager: SoundManager

func _init(scene):
	self.scene = scene
	asset_loader = AssetLoader.new()
	sound_manager = SoundManager.new(self)
	Signals.gun_dropped.connect(_on_gun_dropped)
	Signals.gun_spawned.connect(_on_gun_dropped)
	Signals.bullet_hole_added.connect(_on_bullet_hole_added)
	Signals.enemy_spawned.connect(_on_enemy_spawned)
	Signals.damage_taken.connect(_on_damage_taken)
	Signals.player_spawned.connect(_on_player_spawned)
	Signals.bullet_particle_added.connect(_on_bullet_particle_added)
	Signals.ray_trail_added.connect(_on_ray_trail_added)
	Signals.spell_entity_added.connect(_on_spell_entity_added)
	Signals.gun_picked_up.connect(_on_gun_picked_up)
	Signals.entity_died.connect(_on_entity_died)
	Signals.item_dropped.connect(_on_item_dropped)
# Does not make edits to Core directly, and only edits Scene on core_changed

func _on_item_dropped(payload=null):
	_spawn_node(_get_entity_scene(payload["entity_model"]), scene, Signals.item_dropped, payload)
func _on_gun_dropped(payload=null):
	_spawn_node(_get_entity_scene(payload["entity_model"]), scene, Signals.gun_dropped, payload)
func _on_bullet_hole_added(payload=null):
	_spawn_node(_get_entity_scene(payload["entity_model"]), scene, Signals.bullet_hole_added, payload)
func _on_enemy_spawned(payload=null):
	_spawn_node(_get_entity_scene(payload["entity_model"]), scene, Signals.enemy_spawned, payload)
func _on_damage_taken(payload=null):
	_spawn_node(_get_entity_scene(payload["entity_model"]), scene, Signals.damage_taken, payload)
func _on_player_spawned(payload=null):
	_spawn_node(_get_entity_scene(payload["entity_model"]), scene, Signals.player_spawned, payload)
func _on_bullet_particle_added(payload=null):
	_spawn_node(_get_entity_scene(payload["entity_model"]), scene, Signals.bullet_particle_added, payload)
func _on_ray_trail_added(payload=null):
	_spawn_node(_get_entity_scene(payload["entity_model"]), scene, Signals.ray_trail_added, payload)
func _on_spell_entity_added(payload=null):
	_spawn_node(_get_entity_scene(payload["entity_model"]), scene, Signals.spell_entity_added, payload)
func _on_gun_picked_up(payload=null):
	_remove_node(scene.entity_hash[payload["target_rid"]])
func _on_entity_died(payload=null):
	_remove_node(scene.entity_hash[payload["target_rid"]])

func _spawn_node(node_scene, target_scene, spawn_context, payload = null):
	var new_node: Node3D
	new_node = node_scene.instantiate()
	new_node.position = payload["position"]
	if spawn_context == Signals.gun_dropped:
		new_node.linear_velocity = payload["linear_velocity"]
		new_node.angular_velocity = payload["angular_velocity"]
		new_node.gun_model = payload["gun_model"]
	elif spawn_context == Signals.enemy_spawned:
		new_node.rid = payload["rid"]
		new_node.movement_speed = payload["entity_model"].metadata.movement_speed
		new_node.vision_range = payload["entity_model"].metadata.vision_range
	elif spawn_context == Signals.player_spawned:
		new_node.rid = payload["rid"]
		new_node.movement_speed = payload["entity_model"].metadata.movement_speed
	elif spawn_context == Signals.damage_taken:
		new_node.damage_number = payload["hp_change"]
		new_node.damage_scale = payload["damage_scale"]
	elif spawn_context == Signals.damage_taken:
		new_node.damage_number = payload["hp_change"]
		new_node.damage_scale = payload["damage_scale"]
	elif spawn_context == Signals.item_dropped:
		new_node.damage_number = payload["amount"]
		new_node.damage_scale = float(payload["roll"]) / 100.0
		if payload["loot"]["type"] == "AMMO_DROP":
			new_node.type = DamageNumber.Type.AMMO
		elif payload["loot"]["type"] == "GOLD_DROP":
			new_node.type = DamageNumber.Type.GOLD
	elif spawn_context == Signals.bullet_particle_added:
		new_node.rotation = payload["facing"]
		new_node.emitting = true
		new_node.one_shot = true
	elif spawn_context == Signals.ray_trail_added:
		new_node.direction = payload["direction"].normalized()
		new_node.speed = 120
		new_node.distance = 60
		new_node.position = payload["position"]
	elif spawn_context == Signals.spell_entity_added:
		new_node.rid = payload["rid"]
		new_node.linear_velocity = payload["linear_velocity"]
		new_node.caster = payload["caster"]
		new_node.entity_model = payload["entity_model"]
		
	# TODO: create custom add/free that reuses previously added children
	target_scene.add_child(new_node)
	
	if payload["entity_model"].type == EntityModel.EntityType.removed:
		Core.map.entities.erase(payload["rid"])
	else:
		new_node.rid = payload["rid"]
		scene.entity_hash[payload["rid"]] = new_node
	Signals.core_changed.emit(null)

# TODO: improve behavior for despawning node from scene
func _remove_node(node):
	if Core.player.target_rid == node.rid:
		Core.player.target_rid = 0
		Signals.core_changed.emit(null)
	Core.map.entities.erase(node.rid)
	scene.entity_hash.erase(node.rid)
	node.queue_free()

func _get_entity_scene(entity: EntityModel):
	var new_scene = asset_loader.get_scene(entity.entity_type)
	return new_scene
