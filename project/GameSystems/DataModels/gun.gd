class_name GunModel

var rid: int
var type: GunMetadataModel.GunType
var mag_curr: int

func _init(rid: int, type: GunMetadataModel.GunType, mag_curr: int) -> void:
	self.rid = rid
	self.type = type
	self.mag_curr = mag_curr

static func new_with_full_ammo(type: GunMetadataModel.GunType) -> GunModel:
	return GunModel.new(Core.services.generate_rid(), type, GunMetadataModel.gun_metadata_map[type].mag_size)

var metadata: GunMetadataModel:
	get:
		return GunMetadataModel.gun_metadata_map[type]
		
func _to_string():
	return metadata.name
