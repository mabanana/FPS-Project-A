extends CharacterBody3D
class_name EnemyEntity

enum EnemyState {
	idling,
	chasing,
}
var current_state: EnemyState
const POSITION_FORESHORTEN = 1
var dir: Vector3
var alive = true

var rid: int
var vision_range: float
var movement_speed : float

var core: CoreModel
var core_changed: Signal
var contexts

func bind(core, core_changed):
	self.core = core
	self.core_changed = core_changed
	
	core_changed.connect(_on_core_changed)
	contexts = core.services.Context

func take_damage(damage_amount: int, damage_scale: float, dealer_rid: int, damage_position: Vector3):
	_take_damage(damage_amount, damage_scale, dealer_rid, damage_position)
	
func _on_core_changed(context: CoreServices.Context, payload):
	if context == contexts.damage_dealt and payload["target_rid"] == rid and alive:
		var hp_change = -payload["damage_amount"]
		_add_damage_number_to_map(hp_change, payload["damage_scale"], payload["dealer_rid"], payload["damage_position"])
		_change_hp(hp_change, payload["dealer_rid"])
		

func _add_damage_number_to_map(hp_change: int, damage_scale: float, dealer_rid: int, damage_position: Vector3):
	var direction_to_dealer = position.direction_to(core.map.entities[dealer_rid].position)
	var node_position = (damage_position) + (direction_to_dealer * POSITION_FORESHORTEN)
	var payload = {
		"hp_change" : abs(hp_change),
		"damage_scale" : damage_scale,
		"position" : node_position,
		"entity_model" : EntityModel.new_entity(EntityMetadataModel.EntityType.DAMAGE_NUMBER),
		"rid" : core.services.generate_rid()
		}
	core.map.entities[payload["rid"]] = payload["entity_model"]
	core_changed.emit(contexts.damage_taken, payload)

func _take_damage(damage_amount: int, damage_scale: float, dealer_rid: int, damage_position: Vector3):
	var payload = {
		"dealer_rid" : dealer_rid,
		"target_rid" : rid,
		"damage_amount" : damage_amount,
		"position": global_position,
		"damage_position": damage_position,
		"damage_scale": damage_scale,
	}
	payload = PerkController.apply_perks(contexts.damage_dealt, payload, core, core_changed)
	core_changed.emit(contexts.damage_dealt, payload)

func _change_hp(hp_change, dealer_rid):
	core.map.entities[rid].hp += hp_change
	var payload = {
			"dealer_rid" : dealer_rid,
			"target_name" : core.map.entities[rid].name,
			"target_rid" : rid,
			"hp_change" : hp_change,
			# TODO: move loot class to entitymodel
			"loot_class" : LootManager.LootClass.TEST_SCENE_1_DROP,
	}
	if core.map.entities[rid].hp <= 0:
		alive = false
		payload = PerkController.apply_perks(contexts.entity_died, payload, core, core_changed)
		core_changed.emit(contexts.entity_died, payload)
	else:
		core_changed.emit(contexts.health_changed, payload)
