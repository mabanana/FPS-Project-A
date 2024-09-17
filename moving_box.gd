extends EnemyEntity
class_name MovingBox

var target_position
var nav_agent: NavigationAgent3D
var next_pos
var movement_speed = 5

func _ready():
	hp = 100
	nav_agent = $NavigationAgent3D

func _on_core_changed(context, payload):
	if context == contexts.map_updated:
		var player_pos = payload["player_pos"]
		target_position = player_pos
		nav_agent.target_position = target_position
		

func _physics_process(delta):
	if target_position:
		next_pos = nav_agent.get_next_path_position()
		var dir = global_position.direction_to(next_pos)
		velocity = dir * movement_speed
		if nav_agent.is_navigation_finished:
			target_position = null
	
	move_and_slide()
