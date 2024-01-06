extends Node

#var music_container := Node.new()


#func _ready() -> void:
	#add_child(music_container)


func play_sound_effect(stream: AudioStream) -> void:
	var player := AudioStreamPlayer.new()
	player.stream = stream
	add_child(player)
	player.play()
	await player.finished
	player.queue_free()
