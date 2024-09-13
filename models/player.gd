class_name PlayerModel

var hp: int

var is_ads: bool
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
	sprinting,
	jumping,
	squatting,
	sliding,
	falling
}

func _init(hp: int = 100) -> void:
	self.hp = hp
	is_ads = false
	
	action_state = ActionState.idling
	movement_state = MovementState.standing
