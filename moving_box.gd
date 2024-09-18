extends EnemyEntity
class_name MovingBox

var movement_speed = 5
var nav_ai: AINav

func _ready():
	hp = 100
	nav_ai = AINav.new($NavigationAgent3D)
	nav_ai.bind(core, core_changed)

func _physics_process(delta):
	if nav_ai.target_position:
		dir = global_position.direction_to(nav_ai.next_pos)
		velocity = dir * movement_speed
		if nav_ai.nav_agent.is_navigation_finished:
			nav_ai.target_position = null
	
	move_and_slide()
