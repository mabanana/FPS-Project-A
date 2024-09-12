class_name EntityModel

enum EntityType {
	interactable,
	player,
	enemy,
	npc,
	removed
}

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
