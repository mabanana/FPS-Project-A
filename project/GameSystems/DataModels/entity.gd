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
	return EntityModel.new(entity_type, Vector3.ZERO, Vector3.ZERO, EntityMetadataModel.entity_metadata_map[entity_type].entity_type, Core.services.generate_rid())

var metadata: EntityMetadataModel:
	get:
		return EntityMetadataModel.entity_metadata_map[entity_type]

var rid: int
var position: Vector3
var rotation: Vector3
var transform: Transform3D
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


func _init(entity_type: EntityMetadataModel.EntityType, position: Vector3, rotation: Vector3, type: EntityType, rid: int) -> void:
	self.position = position
	self.rotation = rotation
	self.type = type
	self.entity_type = entity_type
	self.hp = metadata.hp
	self.rid = rid

func _to_string():
	return str(name) + ", " + str(position) + ", " + str(rotation) + ", " + str(type)

func take_damage(damage_amount: int, damage_scale: float, dealer_rid: int, damage_position: Vector3):
	_take_damage(damage_amount, damage_scale, dealer_rid, damage_position)

func _take_damage(damage_amount: int, damage_scale: float, dealer_rid: int, damage_position: Vector3):
	var payload = {
		"dealer_rid" : dealer_rid,
		"target_rid" : rid,
		"damage_amount" : damage_amount,
		"damage_position": damage_position,
		"damage_scale": damage_scale,
	}
	payload = PerkController.apply_perks(Signals.damage_dealt, payload)
	Signals.damage_dealt.emit(payload)
