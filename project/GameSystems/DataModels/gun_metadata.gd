class_name GunMetadataModel

enum GunType {
	TEST_GUN_A,
	TEST_GUN_B,
	TEST_GUN_C,
	TEST_GUN_D,
	RARE_GUN_A,
}

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

static var gun_metadata_map := {}

static func init_gun_metadata_map():
	for i in range(GunType.size()):
		var gun_type = i as GunType
		gun_metadata_map[gun_type] = GunMetadataModel.new(gun_type)

func _init(
	gun_type: GunType
) -> void:
	match gun_type:
		GunType.TEST_GUN_A:
			self.name = "Test SMG"
			self.damage_floor = 3
			self.damage_ceiling = 50
			self.fire_rate = 12
			self.reload_time = 1
			self.accuracy = 75
			self.mag_size = 100
			self.mass = 3
			self.pellet_count = 1
			self.ammo_per_shot = 1
			self.zoom = 2
		GunType.TEST_GUN_B:
			self.name = "Test 2-Shot Pistol"
			self.damage_floor = 70
			self.damage_ceiling = 200
			self.fire_rate = 2
			self.reload_time = 5
			self.accuracy = 90
			self.mag_size = 12
			self.mass = 2
			self.pellet_count = 2
			self.ammo_per_shot = 2
			self.zoom = 1.5
		GunType.TEST_GUN_C:
			self.name = "Test Shotgun"
			self.damage_floor = 10
			self.damage_ceiling = 30
			self.fire_rate = 1.5
			self.reload_time = 2
			self.accuracy = 60
			self.mag_size = 10
			self.mass = 5
			self.pellet_count = 10
			self.ammo_per_shot = 2
			self.zoom = 1.5
		GunType.TEST_GUN_D:
			self.name = "Test Sniper"
			self.damage_floor = 150
			self.damage_ceiling = 200
			self.fire_rate = 1.5
			self.reload_time = 3
			self.accuracy = 95
			self.mag_size = 4
			self.mass = 5
			self.pellet_count = 1
			self.ammo_per_shot = 2
			self.zoom = 4
		GunType.RARE_GUN_A:
			self.name = "Bullet Sprinkler"
			self.damage_floor = 150
			self.damage_ceiling = 200
			self.fire_rate = 10
			self.reload_time = 2
			self.accuracy = 90
			self.mag_size = 40
			self.mass = 7
			self.pellet_count = 10
			self.ammo_per_shot = 4
			self.zoom = 2
		_:
			assert(false, "Unknown GunType")
