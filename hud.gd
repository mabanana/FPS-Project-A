extends Control
class_name HudController

var core: CoreModel
var core_changed: Signal

func update():
	# Update Weapon HUD
	if core.inventory.active_gun_index < len(core.inventory.guns):
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
	if core.player.target_rid > 0:
		%TargetDisplay.modulate.a = 1
		var target_rid = core.player.target_rid
		%TargetHp.value = core.map.entities[target_rid].hp
		%TargetHp.max_value = core.map.entities[target_rid].metadata.hp
		%TargetLabel.text = core.map.entities[target_rid].name
	else:
		%TargetDisplay.modulate.a = 0

# Bindings

func bind(core: CoreModel, core_changed: Signal):
	self.core = core
	self.core_changed = core_changed
	
	core_changed.connect(_on_core_changed)
	_on_bind()

func _on_bind():
	%Minimap.bind(core, core_changed)

func _on_core_changed(context, payload):
	update()
