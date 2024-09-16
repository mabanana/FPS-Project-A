extends Control
class_name HudController

var core: CoreModel
var core_changed: Signal

func update():
	%GunName.text = str(core.inventory.active_gun.metadata.name) if core.inventory.active_gun else ""
	%Total.text = str(core.inventory.ammo)
	%Magazine.text = str(core.inventory.active_gun.mag_curr) if core.inventory.active_gun else "0"
	%HpValue.text = str(core.player.hp)
	%ReloadIndicator.modulate.a = 1 if core.player.action_state == PlayerModel.ActionState.reloading else 0
	%ProgressBar.max_value = core.inventory.active_gun.metadata.mag_size if core.inventory.active_gun else 0
	%ProgressBar.value = core.inventory.active_gun.mag_curr if core.inventory.active_gun else 0

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
