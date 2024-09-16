class_name EntitySpawner
# EntitySpawner is a singleton class listens to all core change signals when entities are added/removed from MapModel.entities dictionary, and then adds/removes entity node to/from the respective scene.

# Change scene var to scene_dict if multiple scenes are active simultaneously
var scene: Node3D
var core: CoreModel
var core_changed: Signal
var contexts: CoreServices.Context
# TODO: Setup Dictionary of all PackedScenes for instatiating 
# Define the list of required PackedScenes for each scene to save on storing every single PackedScene in memory.
var node_scenes: Dictionary

func bind(core, core_changed):
	self.core = core
	self.core_changed = core_changed
	
	core_changed.connect(_on_core_changed)
	contexts = core.services.Context

# Does not make edits to core directly, and only edits Scene on core_changed
func _on_core_changed(context: CoreServices.Context, payload):
	pass

func _spawn_node(node, target_scene, node_properties):
	pass

func _remove_node(node):
	pass
