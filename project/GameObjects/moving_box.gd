extends EnemyEntity
class_name MovingBox

var nav_ai: AiNavigator
var sight: AiSightController
var turn_dir: int

func _ready():
	current_state = EnemyState.idling
	nav_ai = AiNavigator.new($NavigationAgent3D)
	sight = AiSightController.new(self, Vector3(0, 1.5, 0), vision_range)
	Signals.player_spotted.connect(_on_player_spotted)
	turn_dir = 1 if randi_range(0,1) else -1

func _physics_process(delta):
	if nav_ai.target_position and current_state == EnemyState.chasing:
		dir = global_position.direction_to(nav_ai.next_pos)
		var res = sight.cast_ray_towards_target(sight.player_pos, 3)
		if res and res["collider"] and not res["collider"] is PlayerEntity:
			dir = dir.rotated(Vector3.UP, 45 * turn_dir)
			
		velocity.x = dir.x * movement_speed
		velocity.z = dir.z * movement_speed
		if nav_ai.nav_agent.is_navigation_finished:
			nav_ai.target_position = null
	else:
		velocity = Vector3.ZERO
	if !is_on_floor():
		velocity.y += get_gravity().y
		
	move_and_slide()

func _on_player_spotted(payload = null):
	# Temporary state logic
	if payload["observer_rid"] == rid:
		current_state = EnemyState.chasing
		$AnimationPlayer.play("Idle")
