class_name AINav

var target_position
var nav_agent: NavigationAgent3D
var next_pos
var core: CoreModel
var core_changed
var contexts

func bind(core, core_changed):
	self.core = core
	self.core_changed = core_changed
	contexts = core.services.Context
	core_changed.connect(_on_core_changed)

func _init(nav_agent_node: NavigationAgent3D):
	nav_agent = nav_agent_node

func _on_core_changed(context, payload):
	if context == contexts.map_updated:
		var player_pos = payload["player_pos"]
		target_position = player_pos
		nav_agent.target_position = target_position
		next_pos = nav_agent.get_next_path_position()
