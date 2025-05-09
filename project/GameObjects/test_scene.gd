extends GameScene
class_name TestScene

func initialize_scene():
	initialize_test_scene_map()
	core.services.web_debug_mode = false
# Temporary function that initializes the hard coded nodes into test scene.
func initialize_test_scene_map() -> void:
	# Initialize Inventory Model
	core.inventory.guns.append(GunModel.new_with_full_ammo(1, GunMetadataModel.GunType.TEST_GUN_A))
	core.inventory.guns.append(GunModel.new_with_full_ammo(1, GunMetadataModel.GunType.TEST_GUN_B))
	core.inventory.guns.append(GunModel.new_with_full_ammo(1, GunMetadataModel.GunType.TEST_GUN_C))
	core.inventory.guns.append(GunModel.new_with_full_ammo(1, GunMetadataModel.GunType.TEST_GUN_D))
	core_changed.emit(contexts.inventory_accessed, null)
	
	# Initialize Map Model
	_add_entity_to_map(EntityMetadataModel.EntityType.PLAYER, Vector3(0,0,0))
	_add_entity_to_map(EntityMetadataModel.EntityType.TARGET_DUMMY, Vector3(-10,0,10))

	for child in $Map.get_children():
		for marker in child.get_children():
			if marker is Marker3D:
				_add_entity_to_map(EntityMetadataModel.EntityType.MOVING_BOX, marker.global_position)

	if OS.has_feature("web") or core.services.web_debug_mode:
		add_web_button()
	else:
		$AudioStreams.queue_free()
	
	core_changed.emit(contexts.game_loaded, null)

func add_web_button():
	var button = Button.new()
	button.anchor_top = 0.5
	button.set_anchors_preset(Control.PRESET_FULL_RECT)
	button.text = "WEB_CLIENT: Click anywhere to allow the game to accept mouse inputs. You may need to press esc and click a few times for it to work."
	core_changed.connect(func(context, payload):
			if context == contexts.mouse_capture_toggled:
				button.visible = Input.mouse_mode != Input.MOUSE_MODE_CAPTURED
			)
	button.pressed.connect(func():
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		button.hide()
		)
	Hud.add_child(button)
	button.visible = Input.mouse_mode != Input.MOUSE_MODE_CAPTURED
