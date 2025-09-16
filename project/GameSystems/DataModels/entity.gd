class_name EntityModel

enum EntityType {
	removed,
	interactable,
	player,
	enemy,
	npc,
	hitbox,
}

# TODO: Move rid assignment to new_entity
static func new_entity(entity_type:EntityMetadataModel.EntityType) -> EntityModel:
	return EntityModel.new(entity_type, Vector3.ZERO, Vector3.ZERO, EntityMetadataModel.entity_metadata_map[entity_type].entity_type)

var metadata: EntityMetadataModel:
	get:
		return EntityMetadataModel.entity_metadata_map[entity_type]

var position: Vector3
var rotation: Vector3
var type: EntityType
var entity_type: EntityMetadataModel.EntityType
var alive: bool = true
var name:
	get:
		return EntityMetadataModel.entity_metadata_map[entity_type].name
var loot_class: 
	get:
		return EntityMetadataModel.entity_metadata_map[entity_type].loot_class
var hp


func _init(entity_type: EntityMetadataModel.EntityType, position: Vector3, rotation: Vector3, type: EntityType) -> void:
	self.position = position
	self.rotation = rotation
	self.type = type
	self.entity_type = entity_type
	self.hp = metadata.hp

func _to_string():
	return str(name) + ", " + str(position) + ", " + str(rotation) + ", " + str(type)
