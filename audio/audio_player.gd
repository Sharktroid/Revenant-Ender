extends Node

var _music_container := Node.new()
var _track_queue: Dictionary = {}
var _current_track := AudioStreamPlayer.new()


func _ready() -> void:
	add_child(_music_container)


func play_track_effect(stream: AudioStream) -> void:
	_current_track.stream_paused = true
	if stream in _track_queue.keys():
		_current_track = _track_queue[stream]
		_current_track.stream_paused = false
	else:
		_current_track = AudioStreamPlayer.new()
		_current_track.stream = stream
		_music_container.add_child(_current_track)
		_track_queue[stream] = _current_track
		_current_track.play()


func play_sound_effect(stream: AudioStream) -> void:
	var player := AudioStreamPlayer.new()
	player.stream = stream
	add_child(player)
	player.play()
	await player.finished
	player.queue_free()


func clear_track_queue() -> void:
	_music_container.queue_free()
	_music_container = Node.new()
	_track_queue = {}


func stop_track(stream: AudioStream) -> void:
	var track: AudioStreamPlayer = _track_queue[stream]
	track.stop()
	track.queue_free()
	_track_queue.erase(stream)
