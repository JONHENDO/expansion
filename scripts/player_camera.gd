class_name PlayerCamera
extends Camera2D

@export var pan_speed: float = 3.0

var locked: bool = false
var _panning: bool = false
var _target_position: Vector2 = Vector2.ZERO
var _current_room: Area2D = null
var _ready_done: bool = false

func _ready() -> void:
	# Synchronous approximate snap so frame 1 is never wrong
	var rooms := get_tree().get_nodes_in_group("Room")
	if not rooms.is_empty():
		var first: Area2D = _get_leftmost_room(rooms)
		var shape := first.get_node_or_null("CollisionShape2D") as CollisionShape2D
		if shape:
			position = first.position + shape.position
			_target_position = position
			_current_room = first

	# Wait for physics so global transforms are reliable
	await get_tree().physics_frame
	await get_tree().physics_frame
	_snap_to_first_room()
	_ready_done = true

func _physics_process(delta: float) -> void:
	if not _ready_done or locked or not _panning:
		return
	var real_delta := delta / Engine.time_scale
	position = position.lerp(_target_position, pan_speed * real_delta)
	if position.distance_to(_target_position) < 0.5:
		position = _target_position
		_panning = false

func go_to_room(room: Area2D) -> void:
	if locked or room == _current_room:
		return
	_current_room = room
	var new_target := _get_room_center(room)
	var vertical_threshold: float = 8.0
	if abs(new_target.y - position.y) <= vertical_threshold:
		new_target.y = position.y
	_target_position = new_target
	_panning = true

# Called after reload — start camera at the death position and pan to room 1
func pan_from(from_position: Vector2) -> void:
	position = from_position
	var rooms := get_tree().get_nodes_in_group("Room")
	if rooms.is_empty():
		return
	var first := _get_leftmost_room(rooms)
	_current_room = first
	_target_position = _get_room_center(first)
	_panning = true

func current_room() -> Area2D:
	return _current_room

func snap_to_room(room: Area2D) -> void:
	_current_room = room
	_panning = false
	locked = false
	position = _get_room_center(room)

func _snap_to_first_room() -> void:
	var rooms := get_tree().get_nodes_in_group("Room")
	if rooms.is_empty():
		return
	var first := _get_leftmost_room(rooms)
	_current_room = first
	# Only snap if we are not already panning (e.g. death pan-in)
	if not _panning:
		position = _get_room_center(first)
	_target_position = _get_room_center(first)

func _get_leftmost_room(rooms: Array) -> Area2D:
	var first: Area2D = rooms[0]
	for room: Area2D in rooms:
		if room.global_position.x < first.global_position.x:
			first = room
	return first

func _get_room_center(room: Area2D) -> Vector2:
	var shape_node := room.get_node("CollisionShape2D") as CollisionShape2D
	if shape_node == null:
		return room.global_position
	var rect: Rect2 = shape_node.shape.get_rect()
	return shape_node.global_transform * rect.get_center()
