class_name GunMetadataModel

var name: String
var damage_floor: int
var damage_ceiling: int
var fire_rate: float
var reload_time: float
var accuracy: float
var mag_size: int
var mass: float
var pellet_count: int
var ammo_per_shot: int
var zoom: float

# NOTE: Store these as immutable singletons to improve performance
# When adding a new gun, update GunMetadataModel.from() and GunModel.GunType
static var TEST_GUN_A := GunMetadataModel.new("Test SMG", 3, 50, 12, 1, 75, 100, 3, 1, 1, 2)
static var TEST_GUN_B := GunMetadataModel.new("Test 2-Shot Pistol", 70, 200, 2, 5, 90, 12, 2, 2, 2, 1.5)
static var TEST_GUN_C := GunMetadataModel.new("Test Shotgun", 3, 10, 1, 2, 60, 10, 5, 10, 2, 1.5)
static var TEST_GUN_D := GunMetadataModel.new("Test Sniper", 150, 200, 1.5, 3, 95, 4, 5, 1, 2, 4)


func _init(
	name: String,
	damage_floor: int,
	damage_ceiling: int,
	fire_rate: float,
	reload_time: float,
	accuracy: float,
	mag_size: int,
	mass: float,
	pellet_count: int,
	ammo_per_shot: int,
	zoom: float
) -> void:
	self.name = name
	self.damage_floor = damage_floor
	self.damage_ceiling = damage_ceiling
	self.fire_rate = fire_rate
	self.reload_time = reload_time
	self.accuracy = accuracy
	self.mag_size = mag_size
	self.mass = mass
	self.pellet_count = pellet_count
	self.ammo_per_shot = ammo_per_shot if ammo_per_shot else pellet_count
	self.zoom = zoom

static func from(gun_type: GunModel.GunType) -> GunMetadataModel:
	match gun_type:
		GunModel.GunType.TEST_GUN_A:
			return TEST_GUN_A
		GunModel.GunType.TEST_GUN_B:
			return TEST_GUN_B
		GunModel.GunType.TEST_GUN_C:
			return TEST_GUN_C
		GunModel.GunType.TEST_GUN_D:
			return TEST_GUN_D
		_:
			assert(false, "Unknown GunType")
			return null
