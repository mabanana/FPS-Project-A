extends EnemyEntity
class_name MovingBox

var nav_ai: AiNavigator
var sight: AiSightController

func _ready():
	current_state = EnemyState.idling
	hp = 100
	nav_ai = AiNavigator.new($NavigationAgent3D)
	sight = AiSightController.new(self, Vector3(0, 1.5, 0), vision_range)
	nav_ai.bind(core, core_changed)
	sight.bind(core, core_changed)

func _process(delta):
	if current_state == EnemyState.chasing and !$AnimationPlayer.is_playing():
		$AnimationPlayer.play("Idle")

func _physics_process(delta):
	if nav_ai.target_position and current_state == EnemyState.chasing:
		dir = global_position.direction_to(nav_ai.next_pos)
		velocity.x = dir.x * movement_speed
		velocity.z = dir.z * movement_speed
		if nav_ai.nav_agent.is_navigation_finished:
			nav_ai.target_position = null
	else:
		velocity.x = move_toward(velocity.x, 0, movement_speed / 2)
		velocity.z = move_toward(velocity.z, 0, movement_speed / 2)
	if !is_on_floor():
		velocity.y = get_gravity().y
		
	move_and_slide()

func _on_core_changed(context: CoreServices.Context, payload):
	# Temporary state logic
	if context == contexts.player_spotted and payload["observer_rid"] == rid:
		current_state = EnemyState.chasing
