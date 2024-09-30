class_name NodeInstancer

# child of entity spawner and receives scene instantiation and queue_free commands
# should be the only place in the code that has instantiate() and queue_free()
# instantiates a certain number of commmon scenes and provides them to entity spawner instead of instantiating a new scene everytime something is called
# hold a lru cache of instantiated scenes that are inactive, and queue_free() unused scenes
# instantiate new scenes if there are not enough instantiated but entity spawner needs more

var lru
var entity_hash
var remove_pos: Vector3

# Check entity_hash for node matching EntityModel.metadata.EntityType, inject new entity model and return
# If matching not found instantiate a new scene for the entity
func add_node(entity_model: EntityModel):
	pass

# Reset the node's state and move it to a designated location in the scene and disable process
func remove_node(rid: int):
	pass

# free nodes that are too infrequently added to scene
func update_lru(size: int):
	pass

# add commonly used nodes at the remove_pos when a scene starts.
# initialize list is context aware to initialize nodes the scene expects to instatiate.
func initialize_common_nodes(scene_inits: Array):
	pass
