class_name StateMachine

var current_state : State
var parent: Node3D
var animation_tree: AnimationTree
var states : Dictionary = {}

func _init(state_list: Array, parent: Node3D, animation_tree: AnimationTree, current_state: State = null):
	for state in state_list:
		if state is State:
				states[state.name] = state
				# Set the state up with what they need to function
				state.parent = parent
				state.playback = animation_tree["parameters/playback"]
		else:
			push_warning("CharacterStateMachine:  " + state.name + " is not a State for CharacterStateMachine")
	self.parent = parent
	self.animation_tree = animation_tree
	self.current_state = current_state if current_state else state_list[0]

func state_machine_process(delta):
	if current_state.next_state != null:
		print(str(parent.name) + " has entered " + str(current_state.next_state.name) + " from " + str(current_state.name))
		switch_states(current_state.next_state)
	current_state.state_process(delta)

func switch_states(new_state):
	if current_state != null:
		current_state.on_exit()
		current_state.next_state = null
	current_state = new_state
	current_state.on_enter()
	
