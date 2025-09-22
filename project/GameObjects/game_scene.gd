extends Node3D
class_name GameScene

var entity_spawner: EntitySpawner
var loot_manager: LootManager
var Hud: HudController
var hitbox_manager: HitboxManager

@export var pos_update_interval: int

# Hashmap { rid : object_ref }
var entity_hash: Dictionary
var pos_update_cd: Countdown
var player_rid: int

func _ready() -> void:
	# Load all gun metadata
	GunMetadataModel.init_gun_metadata_map()
	EntityMetadataModel.init_entity_metadata_map()
	# Instantiate Helper objects
	entity_spawner = EntitySpawner.new(self)
	loot_manager = LootManager.new()
	hitbox_manager = HitboxManager.new(self)
	Hud = preload("res://UI/hud.tscn").instantiate()
	add_child(Hud)
	# Set up initial state
	entity_hash = {}
	pos_update_cd = Countdown.new(pos_update_interval)	
	# Emit initial state to all observers
	Signals.core_changed.emit(null)
	initialize_scene()

func initialize_scene():
	pass

func _process(delta):
	if pos_update_cd.tick(delta) <= 0:
		_clear_freed()
		if player_rid:
			_pos_update(player_rid)

func _clear_freed():
	for entity_rid in entity_hash:
		if not is_instance_valid(entity_hash[entity_rid]):
			Core.map.entities.erase(entity_rid)
			entity_hash.erase(entity_rid)
			prints(entity_rid, "removed from entity hash")

func _pos_update(origin_rid: ):
	pos_update_cd.reset_cd()
	
	var origin_key = player_rid
	# Update player location
	Core.map.entities[player_rid].position = entity_hash[player_rid].position
	Core.map.entities[player_rid].rotation = entity_hash[player_rid].rotation
	
	# calculate relative positions for minimap based on player
	var entities = Core.map.entities
	var positions: Array[Vector3] = []
	var eye_pos = entity_hash[origin_key].position + entity_hash[origin_key].eye_pos
	for key in entities.keys():
		entities[key].position = entity_hash[key].position
		entities[key].rotation = entity_hash[key].rotation
		entities[key].transform = entity_hash[key].transform
		if entities[key].type == EntityModel.EntityType.enemy:
			var relative_pos = entity_hash[key].position - entity_hash[origin_key].position
			relative_pos = relative_pos.rotated(Vector3.UP, -entities[origin_key].rotation.y)
			relative_pos.y *= -1
			positions.append(relative_pos)
	Core.map.player_pos = entities[origin_key].position
	Signals.map_updated.emit({
		"positions" : positions, 
		"player_pos" : entities[origin_key].position, 
		"player_rid" : player_rid, "player_eye_pos" : eye_pos
		})

func _add_entity_to_map(entity_type: EntityMetadataModel.EntityType, position: Vector3):
	var entity = EntityModel.new_entity(entity_type)
	var rid = entity.rid
	Core.map.entities[rid] = entity
	Core.map.entities[rid].position = position
	if EntityMetadataModel.entity_metadata_map[entity_type].entity_type == EntityModel.EntityType.enemy:
		var payload = {
			"position" : position,
			"rid" : rid,
			"entity_model" : Core.map.entities[rid],
		}
		Signals.enemy_spawned.emit(payload)
	elif entity_type == EntityMetadataModel.EntityType.GUN_ON_FLOOR:
		var payload = {
			"position" : position,
			"rid" : rid,
			"entity_model" : Core.map.entities[rid],
			"gun_model" : GunModel.new_with_full_ammo(GunMetadataModel.GunType.TEST_GUN_D),
			"linear_velocity" : 0,
			"angular_velocity" : 0,
		}
		Signals.gun_dropped.emit(payload)
	elif entity_type == EntityMetadataModel.EntityType.PLAYER:
		var payload = {
			"position" : position,
			"rid" : rid,
			"entity_model" : Core.map.entities[rid],
		}
		player_rid = rid
		Signals.player_spawned.emit(payload)
	return rid
