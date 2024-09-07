class_name GunMetadataModel

# TODO: Add gun mass, pellet count
var name: String
var damage_floor: int
var damage_ceiling: int
var fire_rate: int
var reload_time: int
var accuracy: int
var mag_size: int

# NOTE: Store these as immutable singletons to improve performance
static var TEST_GUN_A := GunMetadataModel.new("Test Gun A", 3, 50, 12, 1, 75, 100)
static var TEST_GUN_B := GunMetadataModel.new("Test Gun B", 70, 200, 2, 5, 90, 12)

func _init(
	name: String,
	damage_floor: int,
	damage_ceiling: int,
	fire_rate: int,
	reload_time: int,
	accuracy: int,
	mag_size: int,
) -> void:
	self.name = name
	self.damage_floor = damage_floor
	self.damage_ceiling = damage_ceiling
	self.fire_rate = fire_rate
	self.reload_time = reload_time
	self.accuracy = accuracy
	self.mag_size = mag_size

static func from(gun_type: GunModel.GunType) -> GunMetadataModel:
	match gun_type:
		GunModel.GunType.TEST_GUN_A:
			return TEST_GUN_A
		GunModel.GunType.TEST_GUN_B:
			return TEST_GUN_B
		_:
			assert(false, "Unknown GunType")
			return null
