class_name EntityMetadataModel

enum EntityType {
	GUN_ON_FLOOR,
	BULLET_HOLE
}

var name: String
var entity_type: EntityModel.EntityType
var oid: int

static var entity_metadata_map := {}

static func init_entity_metadata_map():
	for i in range(EntityType.size()):
		var entity_type = i as EntityType
		entity_metadata_map[entity_type] = EntityMetadataModel.new(entity_type)

func _init(
	entity_type: EntityType
) -> void:
	match entity_type:
		EntityType.GUN_ON_FLOOR:
			self.name = "Gun on Floor"
			self.entity_type = EntityModel.EntityType.interactable
			self.oid = 1001
		EntityType.BULLET_HOLE:
			self.name = "Bullet Hole"
			self.entity_type = EntityModel.EntityType.removed
			self.oid = 5001
		_:
			assert(false, "Unknown EntityType")
