extends EnemyEntity
class_name MovingBox

var nav_ai: AINav

func _ready():
	current_state = EnemyState.idling
	hp = 100
	nav_ai = AINav.new($NavigationAgent3D)
	nav_ai.bind(core, core_changed)

func _physics_process(delta):
	if nav_ai.target_position and current_state == EnemyState.chasing:
		dir = global_position.direction_to(nav_ai.next_pos)
		velocity = dir * movement_speed
		if nav_ai.nav_agent.is_navigation_finished:
			nav_ai.target_position = null
	else:
		velocity.x = move_toward(velocity.x, 0, movement_speed / 2)
		velocity.z = move_toward(velocity.z, 0, movement_speed / 2)
				
	move_and_slide()

func _on_core_changed(context: CoreServices.Context, payload):
	# Temporary state logic
	if context == contexts.gun_shot:
		current_state = EnemyState.chasing
	elif context == contexts.gun_dropped:
		current_state = EnemyState.idling
