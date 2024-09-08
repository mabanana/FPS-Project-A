class_name GunModel

enum GunType {
	TEST_GUN_A,
	TEST_GUN_B,
	TEST_GUN_C,
	TEST_GUN_D
}

var id: int
var type: GunType
var mag_curr: int

func _init(id: int, type: GunType, mag_curr: int) -> void:
	self.id = id
	self.type = type
	self.mag_curr = mag_curr

static func new_with_full_ammo(id: int, type: GunType) -> GunModel:
	return GunModel.new(id, type, GunMetadataModel.from(type).mag_size)

var metadata: GunMetadataModel:
	get:
		return GunMetadataModel.from(type)
		
func _to_string():
	return metadata.name
