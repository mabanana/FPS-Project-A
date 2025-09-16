extends GameScene
class_name TestScene

var enemy_spawners = {}

func initialize_scene():
	if !Core or !Core.loaded:
		await Signals.core_loaded
		pass
	initialize_test_scene_map()
	Core.services.web_debug_mode = false
# Temporary function that initializes the hard coded nodes into test scene.
func initialize_test_scene_map() -> void:
	# Initialize Inventory Model
	Core.inventory.guns.append(GunModel.new_with_full_ammo(1, GunMetadataModel.GunType.TEST_GUN_A))
	Core.inventory.guns.append(GunModel.new_with_full_ammo(1, GunMetadataModel.GunType.TEST_GUN_B))
	Core.inventory.guns.append(GunModel.new_with_full_ammo(1, GunMetadataModel.GunType.TEST_GUN_C))
	Core.inventory.guns.append(GunModel.new_with_full_ammo(1, GunMetadataModel.GunType.TEST_GUN_D))
	Signals.inventory_accessed.emit(null)
	
	# Initialize Map Model
	_add_entity_to_map(EntityMetadataModel.EntityType.PLAYER, Vector3(0,0,0))
	_add_entity_to_map(EntityMetadataModel.EntityType.TARGET_DUMMY, Vector3(-10,0,10))

	for child in $Map.get_children():
		for marker in child.get_children():
			if marker is Marker3D:
				var spawn_delay = 10.0
				var spawner = EnemySpawner.new(
					self, marker.global_position, spawn_delay
				)
				get_tree().create_timer(randf_range(0, spawn_delay)).timeout.connect(
					func():
						spawner.start()
						)
				enemy_spawners[Core.services.generate_rid()] = spawner
	for i in range(3):
		for j in range(5):
			_add_entity_to_map(
				EntityMetadataModel.EntityType.MOVING_BOX,
				Vector3(10 - 1 * i,0,30 - 1 * j))
	
	if OS.has_feature("web") or Core.services.web_debug_mode:
		add_web_button()
	else:
		$AudioStreams.queue_free()
	
	Signals.game_loaded.emit(null)

func add_web_button():
	var button = Button.new()
	button.anchor_top = 0.5
	button.set_anchors_preset(Control.PRESET_FULL_RECT)
	button.text = "WEB_CLIENT: Click anywhere to allow the game to accept mouse inputs. You may need to press esc and click a few times for it to work."
	Signals.mouse_capture_toggled.connect(func(payload = null):
		button.visible = Input.mouse_mode != Input.MOUSE_MODE_CAPTURED
		)
	button.pressed.connect(func():
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		button.hide()
		)
	Hud.add_child(button)
	button.visible = Input.mouse_mode != Input.MOUSE_MODE_CAPTURED
