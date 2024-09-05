class_name GunModel

enum GunType {
	TEST_GUN_A,
	TEST_GUN_B
}

var id: int
var type: GunType
var ammo_count: int

func _init(id: int, type: GunType, ammo_count: int) -> void:
	self.id = id
	self.type = type
	self.ammo_count = ammo_count

static func new_with_full_ammo(id: int, type: GunType) -> GunModel:
	return GunModel.new(id, type, GunMetadataModel.from(type).ammo_capacity)

var metadata: GunMetadataModel:
	get:
		return GunMetadataModel.from(type)
