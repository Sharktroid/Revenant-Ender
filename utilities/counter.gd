## A counter for an integer quantity.
## If initialized with a value, it will emit a signal if it reaches that value.
class_name Counter
extends RefCounted

## Emits when the limit has been reached.
signal limit_reached

var _limit: int
var _count: int = 0


func _init(limit: int = -1) -> void:
	_limit = limit


## Increments the counter by 1. Works even after reaching the limit.
func increment() -> void:
	_count += 1
	if is_limit_reached():
		limit_reached.emit()


## Gets the current count.
func get_count() -> int:
	return _count


## Returns true if the counter has reached the limit.
func is_limit_reached() -> bool:
	return _count >= _limit


## Calls the given function and increments afterwards.
func call_and_increment(function: Callable) -> void:
	await function.call()
	increment()
