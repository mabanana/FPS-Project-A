class_name EntityModel

enum EntityType {
	interactable,
	player,
	enemy,
	npc,
	removed
}

static func new_entity(entity_type:EntityMetadataModel.EntityType) -> EntityModel:
	return EntityModel.new(EntityMetadataModel.entity_metadata_map[entity_type].name, Vector3.ZERO, Vector3.ZERO, EntityMetadataModel.entity_metadata_map[entity_type].entity_type)

var metadata: EntityMetadataModel:
	get:
		return EntityMetadataModel.entity_metadata_map[type]

var position: Vector3
var rotation: Vector3
var type: EntityType
var name: String

func _init(name: String, position: Vector3, rotation: Vector3, type: EntityType) -> void:
	self.position = position
	self.rotation = rotation
	self.type = type
	self.name = name

func _to_string():
	return str(name) + ", " + str(position) + ", " + str(rotation) + ", " + str(type)
