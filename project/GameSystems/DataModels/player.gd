class_name PlayerModel

var target_rid: int
var interact_rid: int
var hp: int
var inventory_size: int

var is_ads: bool
var is_jump: bool

var action_state: ActionState
var movement_state: MovementState

enum ActionState {
	idling,
	triggering,
	reloading,
	throwing
}
enum MovementState {
	standing,
	walking,
	sprinting
}

var perks = {
	PerkController.Perk.double_damage : true,
	PerkController.Perk.heal_on_kill : true,
}

func _init(hp: int = 100) -> void:
	self.hp = hp
	self.inventory_size = 4
	is_ads = false
	is_jump = false

	action_state = ActionState.idling
	movement_state = MovementState.standing
