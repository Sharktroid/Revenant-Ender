extends Node

const BATTLE_SELECT = preload("res://audio/sfx/battle_select.ogg")
const MENU_SELECT = preload("res://audio/sfx/menu_select.ogg")
const DESELECT = preload("res://audio/sfx/deselect.ogg")
const CURSOR = preload("res://audio/sfx/cursor.ogg")

var music_volume: float = 0.5:
	set(value):
		music_volume = value
		if music_volume > 0:
			_current_track.volume_db = _percent_to_db(music_volume)
			_current_track.stream_paused = false
		else:
			_current_track.stream_paused = true
var sfx_volume: float = 1.0

var _music_container := Node.new()
var _track_queue: Dictionary = {}
var _current_track: AudioStreamPlayer
var _current_sfx: Array[AudioStreamPlayer] = []


func _ready() -> void:
	add_child(_music_container)


func play_track(stream: AudioStream) -> void:
	if is_instance_valid(_current_track):
		_current_track.stream_paused = true
	if stream in _track_queue.keys():
		_current_track = _track_queue[stream]
		if music_volume > 0:
			_current_track.stream_paused = false
			fade_in_track(1.0/3)
	else:
		_current_track = AudioStreamPlayer.new()
		_current_track.stream = stream
		_music_container.add_child(_current_track)
		_track_queue[stream] = _current_track
		_current_track.play()
		if music_volume == 0:
			_current_track.stream_paused = true
	_current_track.volume_db = _percent_to_db(music_volume)


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


func clear_track_queue() -> void:
	for child: Node in _music_container.get_children():
		child.queue_free()
	_track_queue = {}


func stop_track() -> void:
	if is_instance_valid(_current_track):
		await fade_out_track()
		_current_track.stop()
		_current_track.queue_free()
		_track_queue.erase(_track_queue.find_key(_current_track))


func pause_track() -> void:
	if is_instance_valid(_current_track):
		await fade_out_track()
		_current_track.stream_paused = true


func fade_in_track(duration: float = 1.0/3) -> void:
	if is_instance_valid(_current_track) and is_inside_tree():
		var tween: Tween = create_tween()
		var set_volume: Callable = func(new_volume: float) -> void:
			_current_track.volume_db = _percent_to_db(new_volume)
		tween.tween_method(set_volume, 0.0, music_volume, duration)


func fade_out_track(duration: float = 1.0/3) -> void:
	if is_instance_valid(_current_track):
		var tween: Tween = create_tween()
		var set_volume: Callable = func(new_volume: float) -> void:
			_current_track.volume_db = _percent_to_db(new_volume)
		tween.tween_method(set_volume, music_volume, 0.0, duration)
		await tween.finished


func clear_sound_effects() -> void:
	for sound_effect: AudioStreamPlayer in _current_sfx:
		sound_effect.queue_free()
	_current_sfx = []


func _percent_to_db(volume: float) -> float:
	if volume == 0: # Fallback; better to manually disable playback
		return -100 # Generally too low to hear
	else:
		return 6 * (log(volume)/log(2))
