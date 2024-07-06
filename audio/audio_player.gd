## Class that handles playing sound effects and sound tracks
extends Node

const _MUSIC_GROUP: StringName = &"music_track"
const _SFX_GROUP: StringName = &"sound_effect"

## The current volume of the music from 0 to 1
var music_volume: float = 0.0:
	set(value):
		music_volume = value
		get_current_player().volume_db = _percent_to_db(music_volume)
		get_current_player().stream_paused = not (music_volume > 0)
## The current volume of sound effects from 0 to 1
var sfx_volume: float = 0.5

var _tracks: Dictionary = {}
var _track_stack: Array[AudioStream]


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
		add_child(new_player)
		new_player.add_to_group(_MUSIC_GROUP)
		new_player.play()
	get_current_player().volume_db = _percent_to_db(music_volume)


func clear_tracks() -> void:
	get_tree().call_group(_MUSIC_GROUP, "queue_free")
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


func fade_in_track(duration: float = 1.0 / 3) -> void:
	if is_instance_valid(get_current_player()) and is_inside_tree():
		var tween: Tween = create_tween()
		tween.tween_method(_set_volume, 0.0, music_volume, duration)


func fade_out_track(duration: float = 1.0 / 3) -> void:
	if is_instance_valid(get_current_player()):
		var tween: Tween = create_tween()
		tween.tween_method(_set_volume, music_volume, 0.0, duration)
		await tween.finished


func stop_and_resume_previous_track() -> void:
	await stop_track()
	resume_track()


func get_current_player() -> AudioStreamPlayer:
	return null if _track_stack.is_empty() else _tracks.get(_track_stack.back())


func play_sound_effect(stream: AudioStream) -> void:
	if sfx_volume > 0:
		var player := AudioStreamPlayer.new()
		player.stream = stream
		add_child(player)
		player.volume_db = _percent_to_db(sfx_volume)
		player.play()
		player.add_to_group(_SFX_GROUP)
		await player.finished
		player.queue_free()


func clear_sound_effects() -> void:
	get_tree().call_group(_SFX_GROUP, "queue_free")


func _percent_to_db(volume: float) -> float:
	return 6 * (log(volume) / log(2)) if volume > 0 else -100.0


func _set_volume(new_volume: float) -> void:
	get_current_player().volume_db = _percent_to_db(new_volume)


class SoundEffects:
	const BATTLE_SELECT = preload("res://audio/sfx/battle_select.ogg")
	const MENU_SELECT = preload("res://audio/sfx/menu_select.ogg")
	const DESELECT = preload("res://audio/sfx/deselect.ogg")
	const CURSOR = preload("res://audio/sfx/cursor.ogg")
	const MENU_TICK = preload("res://audio/sfx/menu_tick.ogg")
	const INVALID = preload("res://audio/sfx/invalid.ogg")
