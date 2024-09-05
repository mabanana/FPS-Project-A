class_name EntityModel

enum EntityType {
	interactable,
	player,
	enemy,
	npc,
	removed
}

var position: Vector3
var entity_type: EntityType
var name: String

func _init(name: String, position: Vector3, entity_type: EntityType) -> void:
	self.position = position
	self.entity_type = entity_type
	self.name = name

func _to_string():
	return str(name) + str(entity_type)
