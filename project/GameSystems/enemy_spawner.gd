class_name EnemySpawner

var variance := 0.15

var position: Vector3
var spawn_cd: float
var active: bool
var scene: GameScene
var spawn_rid = null

func _init(scene: GameScene, position: Vector3, spawn_cd: float):
	self.scene = scene
	self.position = position
	self.spawn_cd = spawn_cd
	active = false

func start():
	active = true
	_trigger_spawn()

func _stop():
	active = false

func _trigger_spawn():
	if not active:
		return
	if (!spawn_rid
	or !Core.map.entities.has(spawn_rid)
	or Core.map.entities[spawn_rid].is_queued_for_deletion()):
		spawn_rid = scene._add_entity_to_map(
			EntityMetadataModel.EntityType.MOVING_BOX, 
			position)
	var respawn_delay = spawn_cd * (1 + randf_range(-variance, variance))
	scene.get_tree().create_timer(respawn_delay).timeout.connect(
		_trigger_spawn
	)
