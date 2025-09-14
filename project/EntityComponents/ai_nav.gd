class_name AiNavigator

var target_position
var nav_agent: NavigationAgent3D
var next_pos

func _init(nav_agent_node: NavigationAgent3D):
	nav_agent = nav_agent_node

func _ready():
	Signals.map_updated.connect(_on_map_updated)

func _on_map_updated(payload=null):
	# TODO: allow for setting target pos to non_player positions
	var player_pos = payload["player_pos"]
	target_position = player_pos
	nav_agent.target_position = target_position
	next_pos = nav_agent.get_next_path_position()
