class_name EntityMetadataModel

enum EntityType {
	GUN_ON_FLOOR,
	BULLET_HOLE,
	PLAYER,
	TARGET_DUMMY,
	DAMAGE_NUMBER,
	BULLET_PARTICLE,
	MOVING_BOX,
	RAY_TRAIL,
	FIRE_BALL,
	PHYSICS_ENEMY,
}

var name: String
var entity_type: EntityModel.EntityType
var hp: int
var movement_speed: float
var vision_range: float
var loot_class: LootManager.LootClass

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
			self.hp = 0
		EntityType.BULLET_HOLE:
			self.name = "Bullet Hole"
			self.entity_type = EntityModel.EntityType.removed
			self.hp = 0
		EntityType.BULLET_PARTICLE:
			self.name = "Bullet Particle"
			self.entity_type = EntityModel.EntityType.removed
			self.hp = 0
		EntityType.PLAYER:
			self.name = "Player"
			self.entity_type = EntityModel.EntityType.player
			self.hp = 100
			self.movement_speed = 10
		EntityType.TARGET_DUMMY:
			self.name = "Target Dummy"
			self.entity_type = EntityModel.EntityType.enemy
			self.hp = 1000000
			self.movement_speed = 0
			self.vision_range = 0
		EntityType.MOVING_BOX:
			self.name = "Moving Box"
			self.entity_type = EntityModel.EntityType.enemy
			self.hp = 100
			self.movement_speed = 5
			self.vision_range = 20
			self.loot_class = LootManager.LootClass.TEST_SCENE_1_DROP
		EntityType.PHYSICS_ENEMY:
			self.name = "Physics Enemy"
			self.entity_type = EntityModel.EntityType.enemy
			self.hp = 100
			self.movement_speed = 5
			self.vision_range = 20
			self.loot_class = LootManager.LootClass.TEST_SCENE_1_DROP
		EntityType.DAMAGE_NUMBER:
			self.name = "Damage Number"
			self.entity_type = EntityModel.EntityType.removed
			self.hp = 0
		EntityType.RAY_TRAIL:
			self.name = "Damage Number"
			self.entity_type = EntityModel.EntityType.removed
			self.hp = 0
		EntityType.FIRE_BALL:
			self.name = "Fire Ball"
			self.entity_type = EntityModel.EntityType.hitbox
			self.hp = 0
		_:
			assert(false, "Unknown EntityType")
