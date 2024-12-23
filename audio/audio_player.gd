## An Autoload that handles playing sound effects and sound tracks
extends Node

const _MUSIC_GROUP: StringName = &"music_track"
const _SFX_GROUP: StringName = &"sound_effect"

var _tracks: Dictionary = {}
var _track_stack: Array[AudioStream]


func _ready() -> void:
	var _update_volume: Callable = func() -> void:
		_get_current_player().volume_db = _percent_to_db(Options.MUSIC.value)
		_get_current_player().stream_paused = not (Options.MUSIC.value > 0)
	Options.MUSIC.value_updated.connect(_update_volume)


## Plays an audio track and pauses any current audio track.
## If the track was previously playing and was not stopped, the track will resume where it left off.
func play_track(stream: AudioStream) -> void:
	if is_instance_valid(_get_current_player()):
		_get_current_player().stream_paused = true
	if stream in _track_stack:
		_track_stack.erase(stream)
		_track_stack.append(stream)
		if Options.MUSIC.value > 0:
			_get_current_player().stream_paused = false
			_fade_in_track()
	else:
		_track_stack.append(stream)
		var new_player := AudioStreamPlayer.new()
		new_player.stream = stream
		if Options.MUSIC.value == 0:
			new_player.stream_paused = true
		_tracks[stream] = new_player
		add_child(new_player)
		new_player.add_to_group(_MUSIC_GROUP)
		new_player.play()
	_get_current_player().volume_db = _percent_to_db(Options.MUSIC.value)


## Stops all tracks. Frees memory.
func clear_tracks() -> void:
	get_tree().call_group(_MUSIC_GROUP, "queue_free")
	_tracks = {}


## Stops the current track.
func stop_track() -> void:
	if is_instance_valid(_get_current_player()):
		await _fade_out_track()
		_get_current_player().stop()
		_get_current_player().queue_free()
		_tracks.erase(_track_stack.pop_back())


## Resumes the last track.
func resume_track() -> void:
	if is_instance_valid(_get_current_player()) and Options.MUSIC.value > 0:
		_get_current_player().stream_paused = false
		_fade_in_track()


## Pauses the currently playing track, allowing it to be resumed later.
func pause_track() -> void:
	if is_instance_valid(_get_current_player()):
		await _fade_out_track()
		_get_current_player().stream_paused = true


## Stops the current track and afterwards starts the previous track.
func stop_and_resume_previous_track() -> void:
	await stop_track()
	resume_track()


## Plays a sound effect.
func play_sound_effect(stream: AudioStream) -> void:
	if Options.SOUND_EFFECTS.value > 0:
		var player := AudioStreamPlayer.new()
		player.stream = stream
		add_child(player)
		player.volume_db = _percent_to_db(Options.SOUND_EFFECTS.value)
		player.play()
		player.add_to_group(_SFX_GROUP)
		await player.finished
		player.queue_free()


## Immediately causes all sound effects to stop playing.
func clear_sound_effects() -> void:
	get_tree().call_group(_SFX_GROUP, "queue_free")


func _fade_in_track(duration: float = 1.0 / 3) -> void:
	if is_instance_valid(_get_current_player()) and is_inside_tree():
		var tween: Tween = create_tween()
		tween.tween_method(_set_volume, 0.0, Options.MUSIC.value, duration)


func _fade_out_track(duration: float = 1.0 / 3) -> void:
	if is_instance_valid(_get_current_player()):
		var tween: Tween = create_tween()
		tween.tween_method(_set_volume, Options.MUSIC.value, 0.0, duration)
		await tween.finished


func _get_current_player() -> AudioStreamPlayer:
	return null if _track_stack.is_empty() else _tracks.get(_track_stack.back())


func _percent_to_db(volume: float) -> float:
	return 6 * (log(volume) / log(2)) if volume > 0 else -100.0


func _set_volume(new_volume: float) -> void:
	_get_current_player().volume_db = _percent_to_db(new_volume)


## A class that stores sound effects.
class SoundEffects:
	## Plays when selecting an option in the menu that causes a unit to end their turn.
	const BATTLE_SELECT: AudioStreamOggVorbis = preload("res://audio/sfx/battle_select.ogg")
	## Plays when an option is selected on a map menu.
	const MENU_SELECT: AudioStreamOggVorbis = preload("res://audio/sfx/menu_select.ogg")
	## Plays when deselecting or backing out of a menu.
	const DESELECT: AudioStreamOggVorbis = preload("res://audio/sfx/deselect.ogg")
	## Plays when moving the cursor (except with mouse).
	const CURSOR: AudioStreamOggVorbis = preload("res://audio/sfx/cursor.ogg")
	## Plays when changing selection in menu.
	const MENU_TICK_V: AudioStreamOggVorbis = preload("res://audio/sfx/menu_tick_vertical.ogg")
	## Plays when changing selection in menu.
	const MENU_TICK_H: AudioStreamOggVorbis = preload("res://audio/sfx/menu_tick_horizontal.ogg")
	## Plays when trying to execute an invalid command.
	const INVALID: AudioStreamOggVorbis = preload("res://audio/sfx/invalid.ogg")
	## Plays when switching units in the status screen.
	const TAB_SWITCH: AudioStreamOggVorbis = preload("res://audio/sfx/status_switch.ogg")
