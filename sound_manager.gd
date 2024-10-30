class_name SoundManager

var core: CoreModel
var core_changed: Signal
var contexts
var entity_spawner: EntitySpawner
var sounds: Dictionary
var sounds_dir = "res://Ninja Adventure - Asset Pack/Sounds/"
var audio_stream_player: AudioStreamPlayer

func _init(entity_spawner: EntitySpawner):
	self.entity_spawner = entity_spawner
	audio_stream_player = AudioStreamPlayer.new()
	audio_stream_player.set_max_polyphony(10)
	entity_spawner.scene.add_child(audio_stream_player)
	sounds = {}
	for folder in DirAccess.get_directories_at(sounds_dir):
		var folder_dir_access = DirAccess.open(sounds_dir+folder)
		for file_name in folder_dir_access.get_files():
			print("sound file found: ", file_name)
			var split_file_name = file_name.split(".")
			var sound_name = split_file_name[0]
			var file_type = split_file_name[len(split_file_name) - 1]
			if file_type in ["wav", "ogg", "mp3"]:
				sounds[sound_name] = sounds_dir + folder + "/" + file_name

func bind(core: CoreModel, core_changed):
	self.core = core
	self.core_changed = core_changed
	contexts = core.services.Context
	
	core_changed.connect(_on_core_changed)

func _on_core_changed(context, payload):
	if context == contexts.gun_shot:
		_spawn_audio_player("Explosion", -30, "Master", Vector2(0.8,0.9))
	elif context == contexts.entity_died and payload["dealer_rid"] == entity_spawner.scene.player_rid:
		_spawn_audio_player("Hit2", -10, "Master", Vector2(0.95, 1.05), payload["target_position"], true)
	elif context == contexts.gun_dropped:
		_spawn_audio_player("Magic1", 10, "Notification" ,Vector2(1.25, 1.35), payload["position"], true)
		
# TODO: use finite number of audio_players instead of instantiating new ones
func _spawn_audio_player(sound_name: String, db_offset: float, bus = "Master", pitch_range: Vector2 = Vector2(0.95, 1.05), position: Vector3 = Vector3.ZERO, is_3d = false):
	var audio_player
	if is_3d:
		audio_player = AudioStreamPlayer3D.new()
		audio_player.position = position
		audio_player.max_db = -6
		audio_player.set_bus(bus)
		audio_player.set_attenuation_model(AudioStreamPlayer3D.ATTENUATION_LOGARITHMIC)
		audio_player.finished.connect(func(): 
			print("audio player freed")
			audio_player.queue_free())
		entity_spawner.scene.add_child(audio_player)
	else:
		audio_player = audio_stream_player
	audio_player.volume_db = db_offset
	audio_player.stream = load(sounds[sound_name])
	# TODO: make pitch range calculated value based on fire rate
	audio_player.pitch_scale = randf_range(pitch_range.x, pitch_range.y)
	audio_player.play()
	
