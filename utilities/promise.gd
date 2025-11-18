class_name Promise
extends RefCounted

signal completed

#var _coroutine: Callable
var _running: bool = true

func _init(...coroutines: Array) -> void:
	if coroutines.is_empty():
		push_error("Promise was created without parameters.")
	else:
		_await(coroutines)


func is_running() -> bool:
	return _running


func _await(coroutines: Array) -> void:
	# Uses back instead of front for perfomance reasons.
	var coroutine: Callable = coroutines.pop_back()
	var sub_promise: Promise
	if not coroutines.is_empty():
		sub_promise = Promise.new.callv(coroutines)
	await coroutine.call()
	if sub_promise and sub_promise.is_running():
		await sub_promise.completed
	_running = false
	completed.emit()
