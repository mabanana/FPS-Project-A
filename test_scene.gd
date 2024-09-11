extends Node3D
class_name TestScene


var core: CoreModel
signal core_changed(context, payload)
var contexts
# TODO Compartmentalize responsibilities into helper classes e.g. entity spawner
@onready var scene_entities: Node3D = %SceneEntities
@onready var dropped_gun: PackedScene = preload("res://gun_on_floor.tscn")
@export var pos_update_interval: int

const UNIT = 100

# Hashmap { id : object_ref }
var entity_hash: Dictionary
var pos_update_cd: int

func _ready() -> void:
	# Instantiate core
	core = CoreModel.new()
	# Add bindings to all relevant observers
	# TODO: bind enemies and NPCs to core and core_changed like player entity
	%Player.bind(core, core_changed)
	%Hud.bind(core, core_changed)
	core_changed.connect(_on_core_changed)
	contexts = core.services.Context
	# Set up initial state
	entity_hash = {}
	pos_update_cd = pos_update_interval
	initialize_test_scene_map()
	# Emit initial state to all observers
	core_changed.emit(core.services.Context.none, null)

# Temporary function that initializes the hard coded nodes into test scene.
func initialize_test_scene_map() -> void:
	# Initialize Inventory Model
	core.inventory.guns.append(GunModel.new_with_full_ammo(1, GunModel.GunType.TEST_GUN_A))
	core.inventory.guns.append(GunModel.new_with_full_ammo(1, GunModel.GunType.TEST_GUN_B))
	core.inventory.guns.append(GunModel.new_with_full_ammo(1, GunModel.GunType.TEST_GUN_C))
	core.inventory.guns.append(GunModel.new_with_full_ammo(1, GunModel.GunType.TEST_GUN_D))
	# Initialize Map Model
	for child in scene_entities.get_children():
		child.id = core.services.generate_id()
		var type: EntityModel.EntityType
		if child is PlayerEntity:
			type = EntityModel.EntityType.player
		elif child is InteractableEntity:
			type = EntityModel.EntityType.interactable
		elif child is EnemyEntity:
			type = EntityModel.EntityType.enemy
		core.map.entities[child.id] = EntityModel.new(child.name, child.position, type)
		entity_hash[child.id] = child

func _process(delta):
	pos_update_cd -= UNIT * delta
	if pos_update_cd <= 0:
		_pos_update()

# Updates Scene to match the state of Core Model
func _on_core_changed(context, payload):
	# Spawns gun node on the map when signal is received
	if context == core.services.Context.gun_dropped:
		print("Gun Node Dropped!")
		var new_dropped_gun = dropped_gun.instantiate()
		new_dropped_gun.position = payload["position"]
		new_dropped_gun.linear_velocity = payload["linear_velocity"]
		new_dropped_gun.angular_velocity = payload["angular_velocity"]
		new_dropped_gun.gun_model = payload["gun_model"]
		new_dropped_gun.id = payload["id"]
		scene_entities.add_child(new_dropped_gun)
		entity_hash[payload["id"]] = new_dropped_gun
	# Removes Gun node from the map when signal is received
	if context == contexts.gun_picked_up:
		# TODO: improve behavior for despawning node from scene
		entity_hash[payload["id"]].queue_free()
		entity_hash.erase(payload["id"])

func _pos_update():
	for key in entity_hash.keys():
		var entity_model = core.map.entities[key]
		entity_model.position = entity_hash[key].position
	pos_update_cd = UNIT * pos_update_interval / 100
	# print(core.map.entities)
	core_changed.emit(contexts.map_updated, null)
