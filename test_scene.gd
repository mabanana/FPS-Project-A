extends Node3D
class_name TestScene


var core: CoreModel
signal core_changed(context, payload)
var contexts
# TODO Compartmentalize responsibilities into helper classes e.g. entity spawner
@onready var scene_entities: Node3D = %SceneEntities
@onready var dropped_gun: PackedScene = preload("res://gun_on_floor.tscn")
@export var pos_update_interval: int

const UNIT = 100

# Hashmap { id : object_ref }
var entity_hash: Dictionary
var pos_update_cd: Countdown

func _ready() -> void:
	# Load all gun metadata
	GunMetadataModel.init_gun_metadata_map()
	# Instantiate core
	core = CoreModel.new()
	# Add bindings to all relevant observers
	# TODO: bind enemies and NPCs to core and core_changed like player entity
	%Player.bind(core, core_changed)
	%Hud.bind(core, core_changed)
	core_changed.connect(_on_core_changed)
	contexts = core.services.Context
	# Set up initial state
	entity_hash = {}
	pos_update_cd = Countdown.new(pos_update_interval)
	initialize_test_scene_map()
	# Emit initial state to all observers
	core_changed.emit(core.services.Context.none, null)

# Temporary function that initializes the hard coded nodes into test scene.
func initialize_test_scene_map() -> void:
	# Initialize Inventory Model
	core.inventory.guns.append(GunModel.new_with_full_ammo(1, GunMetadataModel.GunType.TEST_GUN_A))
	core.inventory.guns.append(GunModel.new_with_full_ammo(1, GunMetadataModel.GunType.TEST_GUN_B))
	core.inventory.guns.append(GunModel.new_with_full_ammo(1, GunMetadataModel.GunType.TEST_GUN_C))
	core.inventory.guns.append(GunModel.new_with_full_ammo(1, GunMetadataModel.GunType.TEST_GUN_D))
	# Initialize Map Model
	for child in scene_entities.get_children():
		child.id = core.services.generate_id()
		var type: EntityModel.EntityType
		if child is PlayerEntity:
			type = EntityModel.EntityType.player
		elif child is InteractableEntity:
			type = EntityModel.EntityType.interactable
		elif child is EnemyEntity:
			type = EntityModel.EntityType.enemy
		core.map.entities[child.id] = EntityModel.new(child.name, child.position, child.rotation, type)
		entity_hash[child.id] = child

func _process(delta):
	if pos_update_cd.tick(delta) <= 0:
		_pos_update()

# Updates Scene to match the state of Core Model
func _on_core_changed(context, payload):
	# Spawns gun node on the map when signal is received
	if context == core.services.Context.gun_dropped:
		print("Gun Node Dropped!")
		var new_dropped_gun = dropped_gun.instantiate()
		new_dropped_gun.position = payload["position"]
		new_dropped_gun.linear_velocity = payload["linear_velocity"]
		new_dropped_gun.angular_velocity = payload["angular_velocity"]
		new_dropped_gun.gun_model = payload["gun_model"]
		new_dropped_gun.id = payload["id"]
		scene_entities.add_child(new_dropped_gun)
		entity_hash[payload["id"]] = new_dropped_gun
	# Removes Gun node from the map when signal is received
	if context == contexts.gun_picked_up:
		# TODO: improve behavior for despawning node from scene
		entity_hash[payload["id"]].queue_free()
		entity_hash.erase(payload["id"])

func _pos_update():
	var player_key
	for key in entity_hash.keys():
		var entity_model = core.map.entities[key]
		if entity_model.type == EntityModel.EntityType.player:
			player_key = key
		entity_model.position = entity_hash[key].position
		entity_model.rotation = entity_hash[key].rotation
	pos_update_cd.reset_cd()
	# print(core.map.entities)
	
	# calculate relative positions for minimap based on player
	var entities = core.map.entities
	var positions: Array[Vector3] = []
	for key in entities.keys():
		if entities[key].type == EntityModel.EntityType.enemy:
			var relative_pos = entities[key].position - entities[player_key].position
			relative_pos = relative_pos.rotated(Vector3.UP, -entities[player_key].rotation.y)
			relative_pos.y *= -1
			positions.append(relative_pos)
	core_changed.emit(contexts.map_updated, {"positions" : positions})
