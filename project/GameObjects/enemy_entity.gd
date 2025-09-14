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
var eye_pos = Vector3(0, 1.2, 0)

var rid: int
var vision_range: float
var movement_speed : float

func _ready():
	Signals.damage_dealt.connect(_on_damage_dealt)

func take_damage(damage_amount: int, damage_scale: float, dealer_rid: int, damage_position: Vector3):
	_take_damage(damage_amount, damage_scale, dealer_rid, damage_position)
	
func _on_damage_dealt(payload = null):
	if payload["target_rid"] == rid and alive:
		var hp_change = -payload["damage_amount"]
		_add_damage_number_to_map(hp_change, payload["damage_scale"], payload["dealer_rid"], payload["damage_position"])
		_change_hp(hp_change, payload["dealer_rid"])

func _add_damage_number_to_map(hp_change: int, damage_scale: float, dealer_rid: int, damage_position: Vector3):
	var direction_to_dealer = position.direction_to(Core.map.entities[dealer_rid].position)
	var node_position = (damage_position) + (direction_to_dealer * POSITION_FORESHORTEN)
	var payload = {
		"hp_change" : abs(hp_change),
		"damage_scale" : damage_scale,
		"position" : node_position,
		"entity_model" : EntityModel.new_entity(EntityMetadataModel.EntityType.DAMAGE_NUMBER),
		"rid" : Core.services.generate_rid()
		}
	Core.map.entities[payload["rid"]] = payload["entity_model"]
	Signals.damage_taken.emit(payload)

func _take_damage(damage_amount: int, damage_scale: float, dealer_rid: int, damage_position: Vector3):
	var payload = {
		"dealer_rid" : dealer_rid,
		"target_rid" : rid,
		"damage_amount" : damage_amount,
		"damage_position": damage_position,
		"damage_scale": damage_scale,
	}
	payload = PerkController.apply_perks(Signals.damage_dealt, payload)
	Signals.damage_dealt.emit(payload)

func _change_hp(hp_change, dealer_rid):
	Core.map.entities[rid].hp += hp_change
	var payload = {
			"dealer_rid" : dealer_rid,
			"target_name" : Core.map.entities[rid].name,
			"target_rid" : rid,
			"hp_change" : hp_change,
			"loot_class" : Core.map.entities[rid].loot_class,
			"target_position": global_position + eye_pos
	}
	if Core.map.entities[rid].hp <= 0:
		alive = false
		payload = PerkController.apply_perks(Signals.entity_died, payload)
		Signals.entity_died.emit(payload)
	else:
		Signals.health_changed.emit(payload)
