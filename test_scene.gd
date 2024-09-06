extends Node3D

var core: CoreModel
signal core_changed
var id_counter: int
@onready var scene_entities: Node3D = %SceneEntities

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Starts ID generator
	id_counter = 0
	# Instantiate core
	core = CoreModel.new()
	# Add bindings to all relevant observers
	%Player.bind(core, core_changed)
	%Hud.bind(core, core_changed)
	scene_entities.child_entered_tree.connect(_on_new_entity_entered)
	scene_entities.child_exiting_tree.connect(_on_entity_exiting)
	core_changed.connect(_on_core_changed)
	# Set up initial state
	core.inventory.guns.append(GunModel.new_with_full_ammo(1, GunModel.GunType.TEST_GUN_A))
	core.inventory.guns.append(GunModel.new_with_full_ammo(1, GunModel.GunType.TEST_GUN_A))
	core.inventory.guns.append(GunModel.new_with_full_ammo(1, GunModel.GunType.TEST_GUN_B))
	initialize_test_scene_map()
	# Emit initial state to all observers
	core_changed.emit()

func initialize_test_scene_map() -> void:
	for child in scene_entities.get_children():
		_on_new_entity_entered(child)

func _add_entity_to_map(id:int, entity:EntityModel) -> void:
	core.map.entities[id] = entity
	core_changed.emit()

func _remove_entity_from_map(id) -> void:
	core.map.entities.erase(id)
	core_changed.emit()

func generate_id() -> int:
	var new_id = id_counter
	id_counter += 1
	return new_id

func _on_new_entity_entered(node):
	var type: EntityModel.EntityType
	var new_id = generate_id()
	if node is PlayerEntity:
		type = EntityModel.EntityType.player
	elif node is InteractableEntity:
		type = EntityModel.EntityType.interactable
	elif node is EnemyEntity:
		type = EntityModel.EntityType.enemy
	_add_entity_to_map(new_id, EntityModel.new(node.name, node.position, type))
	node.id = new_id

func _on_entity_exiting(node):
	_remove_entity_from_map(node.id)

func _on_core_changed():
	var player_count = 0
	var enemy_count = 0
	var gun_count = 0
	for key in core.map.entities.keys():
		if core.map.entities[key].entity_type == EntityModel.EntityType.player:
			player_count += 1
		elif core.map.entities[key].entity_type == EntityModel.EntityType.enemy:
			enemy_count += 1
		elif core.map.entities[key].entity_type == EntityModel.EntityType.interactable:
			gun_count += 1
