## A data structure that holds unique values in no particular order.
class_name Set
extends RefCounted

var _dict: Dictionary[Variant, bool] = {}


# TODO: make vararg
func _init(array: Array = []) -> void:
	append_array(array)


func _iter_init(iter: Array) -> bool:
	iter[0] = 0
	return iter[0] < _dict.size()


func _iter_next(iter: Array) -> bool:
	iter[0] += 1
	return iter[0] < _dict.size()


func _iter_get(iter: Variant) -> Variant:
	return _dict.keys()[iter]


func _to_string() -> String:
	return str(_dict.keys())


## Returns true if the set contains the given element, if not false.
func has(variant: Variant) -> bool:
	return _dict.has(variant)


## Returns an array of all the elements in this set. Elements will be returned in a deterministic order.
func to_array() -> Array:
	return _dict.keys()


## Returns true if the set is empty, otherwise false.
func is_empty() -> bool:
	return _dict.is_empty()


## Adds every element in an array to the set.
func append_array(array: Array) -> void:
	for element: Variant in array:
		_dict[element] = true


## Adds every element in another set to this set.
func append_set(new_set: Set) -> void:
	append_array(new_set.to_array())


## Returns a new set containing all of the elements in this set.
func duplicate() -> Set:
	return Set.new(to_array())


## Returns a new set containing all of the elements in this set that return true for the given callable.
func filter(callable: Callable) -> Set:
	return Set.new(_dict.keys().filter(callable))


## Removes an element from the set.
func erase(element: Variant) -> void:
	_dict.erase(element)


## Returns the number of elements in the set.
func size() -> int:
	return _dict.size()
