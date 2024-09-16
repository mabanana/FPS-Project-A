extends Control
class_name HudController

var core: CoreModel
var core_changed: Signal

func update():
	if core.inventory.active_gun_index < len(core.inventory.guns):
		%GunName.text = str(core.inventory.active_gun.metadata.name)
		%Magazine.text = str(core.inventory.active_gun.mag_curr)
		%ProgressBar.max_value = core.inventory.active_gun.metadata.mag_size 
		%ProgressBar.value = core.inventory.active_gun.mag_curr
		$VBoxContainer2.modulate.a = 1
	else:
		$VBoxContainer2.modulate.a = 0
	%Total.text = str(core.inventory.ammo)
	%HpValue.text = str(core.player.hp)
	%ReloadIndicator.modulate.a = 1 if core.player.action_state == PlayerModel.ActionState.reloading else 0
	

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
