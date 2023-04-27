extends Button

signal been_pressed(emitter: Button)


#func _init():


func _pressed():
	been_pressed.emit(self)
