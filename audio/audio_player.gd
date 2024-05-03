extends Node

const BATTLE_SELECT = preload("res://audio/sfx/battle_select.ogg")
const MENU_SELECT = preload("res://audio/sfx/menu_select.ogg")
const DESELECT = preload("res://audio/sfx/deselect.ogg")
const CURSOR = preload("res://audio/sfx/cursor.ogg")

var music_volume: float = 0.5:
	set(value):
		music_volume = value
		if music_volume > 0:
			get_current_player().volume_db = _percent_to_db(music_volume)
			get_current_player().stream_paused = false
		else:
			get_current_player().stream_paused = true
var sfx_volume: float = 1.0

var _music_container := Node.new()
var _tracks: Dictionary = {}
var _track_stack: Array[AudioStream]
var _current_sfx: Array[AudioStreamPlayer] = []


func _ready() -> void:
	add_child(_music_container)


func play_track(stream: AudioStream) -> void:
	if is_instance_valid(get_current_player()):
		get_current_player().stream_paused = true
	if stream in _track_stack:
		_track_stack.erase(stream)
		_track_stack.append(stream)
		if music_volume > 0:
			get_current_player().stream_paused = false
			fade_in_track()
	else:
		_track_stack.append(stream)
		var new_player := AudioStreamPlayer.new()
		new_player.stream = stream
		if music_volume == 0:
			new_player.stream_paused = true
		_tracks[stream] = new_player
		_music_container.add_child(new_player)
		new_player.play()
	get_current_player().volume_db = _percent_to_db(music_volume)


func clear_tracks() -> void:
	for child: Node in _music_container.get_children():
		child.queue_free()
	_tracks = {}


func stop_track() -> void:
	if is_instance_valid(get_current_player()):
		await fade_out_track()
		get_current_player().stop()
		get_current_player().queue_free()
		_tracks.erase(_track_stack.pop_back())



func resume_track() -> void:
	if is_instance_valid(get_current_player()) and music_volume > 0:
		get_current_player().stream_paused = false
		fade_in_track()


func pause_track() -> void:
	if is_instance_valid(get_current_player()):
		await fade_out_track()
		get_current_player().stream_paused = true


func fade_in_track(duration: float = 1.0/3) -> void:
	if is_instance_valid(get_current_player()) and is_inside_tree():
		var tween: Tween = create_tween()
		var set_volume: Callable = func(new_volume: float) -> void:
			get_current_player().volume_db = _percent_to_db(new_volume)
		tween.tween_method(set_volume, 0.0, music_volume, duration)


func fade_out_track(duration: float = 1.0/3) -> void:
	if is_instance_valid(get_current_player()):
		var tween: Tween = create_tween()
		var set_volume: Callable = func(new_volume: float) -> void:
			get_current_player().volume_db = _percent_to_db(new_volume)
		tween.tween_method(set_volume, music_volume, 0.0, duration)
		await tween.finished


func get_current_player() -> AudioStreamPlayer:
	if (_track_stack.size() == 0):
		return null
	else:
		return _tracks.get(_track_stack.back())


func play_sound_effect(stream: AudioStream) -> void:
	if sfx_volume > 0:
		var player := AudioStreamPlayer.new()
		player.stream = stream
		add_child(player)
		player.volume_db = _percent_to_db(sfx_volume)
		player.play()
		_current_sfx.append(player)
		await player.finished
		_current_sfx.erase(player)
		player.queue_free()


func clear_sound_effects() -> void:
	for sound_effect: AudioStreamPlayer in _current_sfx:
		sound_effect.queue_free()
	_current_sfx = []


func _percent_to_db(volume: float) -> float:
	if volume == 0: # Fallback; better to manually disable playback
		return -100 # Generally too low to hear
	else:
		return 6 * (log(volume)/log(2))
