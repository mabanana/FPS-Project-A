extends Control
class_name HudController

var core: CoreModel
var core_changed: Signal
var contexts

var show_gun_preview = true

func update():
	# Update Weapon HUD
	if core.inventory.active_gun:
		%GunName.text = str(core.inventory.active_gun.metadata.name)
		%Magazine.text = str(core.inventory.active_gun.mag_curr)
		%ProgressBar.max_value = core.inventory.active_gun.metadata.mag_size 
		%ProgressBar.value = core.inventory.active_gun.mag_curr
		%WeaponDisplay.modulate.a = 1
		%Total.text = str(core.inventory.ammo)
		%ReloadIndicator.modulate.a = 1 if core.player.action_state == PlayerModel.ActionState.reloading else 0
	else:
		%WeaponDisplay.modulate.a = 0
	
	# Update Status HUD
	%HpValue.text = str(core.player.hp)

	# Update Target Display
	# TODO: create target display for interactables
	if core.player.target_rid > 0:
		%TargetDisplay.modulate.a = 1
		var target_rid = core.player.target_rid
		%TargetHp.modulate.a = 1
		%TargetHp.value = core.map.entities[target_rid].hp
		%TargetHp.max_value = core.map.entities[target_rid].metadata.hp
		%TargetLabel.text = core.map.entities[target_rid].name
	elif core.player.interact_rid > 0:
		%TargetDisplay.modulate.a = 1
		var target_rid = core.player.interact_rid
		%TargetHp.modulate.a = 0
		var entity_hash = get_parent().entity_hash
		if target_rid in entity_hash:
			%TargetLabel.text = entity_hash[target_rid].gun_model.metadata.name
		else:
			core.player.interact_rid = -1
			core_changed.emit(contexts.none, null)
	else:
		%TargetDisplay.modulate.a = 0
	
	

# Bindings

func bind(core: CoreModel, core_changed: Signal):
	self.core = core
	self.core_changed = core_changed
	contexts = core.services.Context
	
	core_changed.connect(_on_core_changed)
	_on_bind()

func _on_bind():
	%Minimap.bind(core, core_changed)
	%ScrollContainer.bind(core, core_changed)
	%DragSpace.bind(core, core_changed)
	
func _on_core_changed(context, payload):
	update()
	if context == contexts.mouse_capture_toggled:
		%GunPreviewViewport.visible = (payload["prev_mode"] == Input.MOUSE_MODE_CAPTURED) and show_gun_preview
	elif context == contexts.gun_swapped:
		%GunPreviewViewport.update_mesh(payload["array_mesh"])
	elif context == contexts.event_input_pressed:
		if payload["action"] == InputHandler.PlayerActions.TOGGLE_GUN_PREVIEW:
			show_gun_preview = !show_gun_preview
		%GunPreviewViewport.visible = (Input.mouse_mode == Input.MOUSE_MODE_VISIBLE) and show_gun_preview

func _notification(what):
	match what:
		NOTIFICATION_DRAG_END:
			print("drag end", core.services.gui_hover)
			core_changed.emit(contexts.drag_ended, 
			{
				"gui_drag": core.services.gui_drag,
				"gui_hover": core.services.gui_hover
			})
			core.services.gui_drag = null
		NOTIFICATION_DRAG_BEGIN:
			core.services.gui_drag = get_viewport().gui_get_drag_data()
			prints("drag start", core.services.gui_drag)
			core_changed.emit(contexts.drag_started, {
				"gui_drag": core.services.gui_drag
			})
