class_name GunModel

var id: int
var type: GunMetadataModel.GunType
var mag_curr: int

func _init(id: int, type: GunMetadataModel.GunType, mag_curr: int) -> void:
	self.id = id
	self.type = type
	self.mag_curr = mag_curr

static func new_with_full_ammo(id: int, type: GunMetadataModel.GunType) -> GunModel:
	return GunModel.new(id, type, GunMetadataModel.gun_metadata_map[type].mag_size)

var metadata: GunMetadataModel:
	get:
		return GunMetadataModel.gun_metadata_map[type]
		
func _to_string():
	return metadata.name
