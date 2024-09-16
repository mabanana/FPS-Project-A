extends Node3D
class_name TestScene


var core: CoreModel
signal core_changed(context, payload)
var contexts
var entity_spawner
@onready var scene_entities: Node3D = %SceneEntities
@onready var dropped_gun: PackedScene = preload("res://gun_on_floor.tscn")
@export var pos_update_interval: int

const UNIT = 100

# Hashmap { rid : object_ref }
var entity_hash: Dictionary
var pos_update_cd: Countdown

func _ready() -> void:
	# Load all gun metadata
	GunMetadataModel.init_gun_metadata_map()
	EntityMetadataModel.init_entity_metadata_map()
	# Instantiate core
	core = CoreModel.new()
	entity_spawner = EntitySpawner.new(self)
	# Add bindings to all relevant observers
	# TODO: bind enemies and NPCs to core and core_changed like player entity
	entity_spawner.bind(core, core_changed)
	%Player.bind(core, core_changed)
	%Hud.bind(core, core_changed)
	core_changed.connect(_on_core_changed)
	contexts = core.services.Context
	# Set up initial state
	entity_hash = {}
	pos_update_cd = Countdown.new(pos_update_interval)
	initialize_test_scene_map()
	_add_entity_to_map(EntityMetadataModel.EntityType.TARGET_DUMMY, Vector3(-10,1,10))
	_add_entity_to_map(EntityMetadataModel.EntityType.TARGET_DUMMY, Vector3(10,1,-10))
	_add_entity_to_map(EntityMetadataModel.EntityType.TARGET_DUMMY, Vector3(10,1,10))
	_add_entity_to_map(EntityMetadataModel.EntityType.TARGET_DUMMY, Vector3(-10,1,-10))
	# Emit initial state to all observers
	core_changed.emit(contexts.none, null)

# Temporary function that initializes the hard coded nodes into test scene.
func initialize_test_scene_map() -> void:
	# Initialize Inventory Model
	core.inventory.guns.append(GunModel.new_with_full_ammo(1, GunMetadataModel.GunType.TEST_GUN_A))
	core.inventory.guns.append(GunModel.new_with_full_ammo(1, GunMetadataModel.GunType.TEST_GUN_B))
	core.inventory.guns.append(GunModel.new_with_full_ammo(1, GunMetadataModel.GunType.TEST_GUN_C))
	core.inventory.guns.append(GunModel.new_with_full_ammo(1, GunMetadataModel.GunType.TEST_GUN_D))
	core_changed.emit(contexts.gun_swap_started, {"is_cycle": false, "prev_index" : 0})
	# Initialize Map Model
	for child in scene_entities.get_children():
		var type: EntityModel.EntityType
		if child is PlayerEntity:
			child.rid = core.services.generate_rid()
			print("player id is " + str(child.rid))
			core.map.entities[child.rid] = EntityModel.new_entity(EntityMetadataModel.EntityType.PLAYER)
			core.map.entities[child.rid].position = child.position
			entity_hash[child.rid] = child
		elif child is InteractableEntity:
			_add_entity_to_map(EntityMetadataModel.EntityType.GUN_ON_FLOOR, child.position)
		elif child is EnemyEntity:
			_add_entity_to_map(EntityMetadataModel.EntityType.TARGET_DUMMY, child.position)
		

func _process(delta):
	if pos_update_cd.tick(delta) <= 0:
		_pos_update()

func _on_core_changed(context, payload):
	pass

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

func _add_entity_to_map(entity_type: EntityMetadataModel.EntityType, position: Vector3):
	var rid = core.services.generate_rid()
	core.map.entities[rid] = EntityModel.new_entity(entity_type)
	core.map.entities[rid].position = position
	if entity_type == EntityMetadataModel.EntityType.TARGET_DUMMY:
		var payload = {
			"position" : position,
			"rid" : rid,
			"entity_model" : core.map.entities[rid],
		}
		core_changed.emit(contexts.enemy_spawned, payload)
	elif entity_type == EntityMetadataModel.EntityType.GUN_ON_FLOOR:
		var payload = {
			"position" : position,
			"rid" : rid,
			"entity_model" : core.map.entities[rid],
			"gun_model" : GunModel.new_with_full_ammo(1, GunMetadataModel.GunType.TEST_GUN_D),
			"linear_velocity" : 0,
			"angular_velocity" : 0,
		}
		core_changed.emit(contexts.gun_dropped, payload)
	elif entity_type == EntityMetadataModel.EntityType.PLAYER:
		var payload = {
			"position" : position,
			"rid" : rid,
			"entity_model" : core.map.entities[rid],
		}
	
