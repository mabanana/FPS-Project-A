extends Control
class_name HudController

var show_gun_preview = true

func _ready():
	if !Core or !Core.loaded:
		await Signals.core_loaded
		pass
	Signals.core_changed.connect(_on_core_changed)
	Signals.mouse_capture_toggled.connect(_on_mouse_capture_toggled)
	Signals.gun_swapped.connect(_on_gun_swapped)
	Signals.event_input_pressed.connect(_on_event_input_pressed)

func update():
	# Update Weapon HUD
	if Core.inventory.active_gun:
		%GunName.text = str(Core.inventory.active_gun.metadata.name)
		%Magazine.text = str(Core.inventory.active_gun.mag_curr)
		%ProgressBar.max_value = Core.inventory.active_gun.metadata.mag_size 
		%ProgressBar.value = Core.inventory.active_gun.mag_curr
		%WeaponDisplay.modulate.a = 1
		%Total.text = str(Core.inventory.ammo)
		%ReloadIndicator.modulate.a = 1 if Core.player.action_state == PlayerModel.ActionState.reloading else 0
	else:
		%WeaponDisplay.modulate.a = 0
	
	# Update Status HUD
	%HpValue.text = str(Core.player.hp)

	# Update Target Display
	# TODO: create target display for interactables
	if Core.player.target_rid > 0:
		%TargetDisplay.modulate.a = 1
		var target_rid = Core.player.target_rid
		%TargetHp.modulate.a = 1
		%TargetHp.value = Core.map.entities[target_rid].hp
		%TargetHp.max_value = Core.map.entities[target_rid].metadata.hp
		%TargetLabel.text = Core.map.entities[target_rid].name
	elif Core.player.interact_rid > 0:
		%TargetDisplay.modulate.a = 1
		var target_rid = Core.player.interact_rid
		%TargetHp.modulate.a = 0
		var entity_hash = get_parent().entity_hash
		if target_rid in entity_hash:
			%TargetLabel.text = entity_hash[target_rid].gun_model.metadata.name
		else:
			Core.player.interact_rid = -1
			Signals.core_changed.emit(null)
	else:
		%TargetDisplay.modulate.a = 0

func _on_core_changed(payload = null):
	update()
func _on_mouse_capture_toggled(payload = null):
	%GunPreviewViewport.visible = (payload["prev_mode"] == Input.MOUSE_MODE_CAPTURED) and show_gun_preview
func _on_gun_swapped(payload = null):
	%GunPreviewViewport.update_mesh(payload["array_mesh"])
func _on_event_input_pressed(payload = null):
	if payload["action"] == InputHandler.PlayerActions.TOGGLE_GUN_PREVIEW:
		show_gun_preview = !show_gun_preview
	%GunPreviewViewport.visible = (Input.mouse_mode == Input.MOUSE_MODE_VISIBLE) and show_gun_preview

func _notification(what):
	match what:
		NOTIFICATION_DRAG_END:
			print("drag end", Core.services.gui_hover)
			Signals.drag_ended.emit(
			{
				"gui_drag": Core.services.gui_drag,
				"gui_hover": Core.services.gui_hover
			})
			Core.services.gui_drag = null
		NOTIFICATION_DRAG_BEGIN:
			Core.services.gui_drag = get_viewport().gui_get_drag_data()
			prints("drag start", Core.services.gui_drag)
			Signals.drag_started.emit({
				"gui_drag": Core.services.gui_drag
			})
