extends Polygon2D

enum Shapes { DEFAULT, SQUISHED, TALL, SLIGHT_SQUISHED }

#region Shape Nodes
@onready var _inner_coloring := $InnerColoring as Polygon2D
@onready var _squished_arrow := $SquishedArrow as Polygon2D
@onready var _squished_arrow_inner := $"SquishedArrow/SquishedInner" as Polygon2D
@onready var _tall_arrow := $TallArrow as Polygon2D
@onready var _tall_arrow_inner := $"TallArrow/TallInner" as Polygon2D
@onready var _slight_squished_arrow := $SlightSquishedArrow as Polygon2D
@onready var _slight_squished_arrow_inner := $"SlightSquishedArrow/SlightSquishedInner" as Polygon2D
#endregion

#region Shape Polygons
@onready var _default_outer: PackedVector2Array = polygon
@onready var _default_inner: PackedVector2Array = ($InnerColoring as Polygon2D).polygon
@onready var _squished_outer: PackedVector2Array = _squished_arrow.polygon
@onready var _squished_inner: PackedVector2Array = _squished_arrow_inner.polygon
@onready var _tall_outer: PackedVector2Array = _tall_arrow.polygon
@onready var _tall_inner: PackedVector2Array = _tall_arrow_inner.polygon
@onready var _slight_squished_outer: PackedVector2Array = _slight_squished_arrow.polygon
@onready var _slight_squished_inner: PackedVector2Array = _slight_squished_arrow_inner.polygon
#endregion


func _ready() -> void:
	_squished_arrow.queue_free()
	_tall_arrow.queue_free()
	_squished_arrow_inner.queue_free()


func _process(delta: float) -> void:
	_inner_coloring.texture_offset.y += 64.0 / 60 * 8 * delta


func set_shape(shape: Shapes) -> void:
	match shape:
		Shapes.DEFAULT:
			polygon = _default_outer
			_inner_coloring.polygon = _default_inner
		Shapes.SQUISHED:
			polygon = _squished_outer
			_inner_coloring.polygon = _squished_inner
		Shapes.SLIGHT_SQUISHED:
			polygon = _slight_squished_outer
			_inner_coloring.polygon = _slight_squished_inner
		Shapes.TALL:
			polygon = _tall_outer
			_inner_coloring.polygon = _tall_inner
