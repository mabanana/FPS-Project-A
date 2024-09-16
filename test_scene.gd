extends Node3D
class_name TestScene

var core: CoreModel
signal core_changed(context, payload)
var contexts
var entity_spawner: EntitySpawner
var Hud: HudController

@export var pos_update_interval: int

const UNIT = 100

# Hashmap { rid : object_ref }
var entity_hash: Dictionary
var pos_update_cd: Countdown
var player_rid: int

func _ready() -> void:
	# Load all gun metadata
	GunMetadataModel.init_gun_metadata_map()
	EntityMetadataModel.init_entity_metadata_map()
	# Instantiate core
	core = CoreModel.new()
	entity_spawner = EntitySpawner.new(self)
	# Add bindings to all relevant observers
	entity_spawner.bind(core, core_changed)
	Hud = %Hud
	Hud.bind(core, core_changed)
	core_changed.connect(_on_core_changed)
	contexts = core.services.Context
	
	# Set up initial state
	entity_hash = {}
	initialize_test_scene_map()
	pos_update_cd = Countdown.new(pos_update_interval)
	
	
	# Emit initial state to all observers
	core_changed.emit(contexts.none, null)

# Temporary function that initializes the hard coded nodes into test scene.
func initialize_test_scene_map() -> void:
	# Initialize Inventory Model
	core.inventory.guns.append(GunModel.new_with_full_ammo(1, GunMetadataModel.GunType.TEST_GUN_A))
	core.inventory.guns.append(GunModel.new_with_full_ammo(1, GunMetadataModel.GunType.TEST_GUN_B))
	core.inventory.guns.append(GunModel.new_with_full_ammo(1, GunMetadataModel.GunType.TEST_GUN_C))
	core.inventory.guns.append(GunModel.new_with_full_ammo(1, GunMetadataModel.GunType.TEST_GUN_D))
	
	# Initialize Map Model
	_add_entity_to_map(EntityMetadataModel.EntityType.PLAYER, Vector3(0,1,0))
		
	_add_entity_to_map(EntityMetadataModel.EntityType.TARGET_DUMMY, Vector3(-10,1,10))
	_add_entity_to_map(EntityMetadataModel.EntityType.TARGET_DUMMY, Vector3(10,1,-10))
	_add_entity_to_map(EntityMetadataModel.EntityType.TARGET_DUMMY, Vector3(10,1,10))
	_add_entity_to_map(EntityMetadataModel.EntityType.TARGET_DUMMY, Vector3(-10,1,-10))
			

func _process(delta):
	if pos_update_cd.tick(delta) <= 0:
		if player_rid:
			_pos_update(player_rid)

func _on_core_changed(context, payload):
	pass

func _pos_update(origin_rid: ):
	var origin_key = player_rid
	# Update player location
	core.map.entities[player_rid].position = entity_hash[player_rid].position
	core.map.entities[player_rid].rotation = entity_hash[player_rid].rotation
			
	
	pos_update_cd.reset_cd()
	
	# calculate relative positions for minimap based on player
	var entities = core.map.entities
	var positions: Array[Vector3] = []
	for key in entities.keys():
		if entities[key].type == EntityModel.EntityType.enemy:
			var relative_pos = entities[key].position - entities[origin_key].position
			relative_pos = relative_pos.rotated(Vector3.UP, -entities[origin_key].rotation.y)
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
		player_rid = rid
		core_changed.emit(contexts.player_spawned, payload)
	
