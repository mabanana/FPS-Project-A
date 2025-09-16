extends CharacterBody3D
class_name EnemyEntity

enum EnemyState {
	idling,
	chasing,
}
var current_state: EnemyState
var dir: Vector3
var alive: bool:
	get():
		return Core.map.entities[rid] and Core.map.entities[rid].alive
var eye_pos = Vector3(0, 1.2, 0)

var rid: int
var vision_range: float
var movement_speed : float

func take_damage(damage_amount: int, damage_scale: float, dealer_rid: int, damage_position: Vector3):
	_take_damage(damage_amount, damage_scale, dealer_rid, damage_position)

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
