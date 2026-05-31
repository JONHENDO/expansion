extends Node

var room_pause: bool = false
@export var room_pause_time: float = 0.2

var _camera: PlayerCamera
var _player: CharacterBody2D
var _initialised: bool = false
var _death_in_progress: bool = false

# Persists across scene reloads — stores the room the player died in
var death_room_position: Vector2 = Vector2.ZERO
var died_away_from_start: bool = false

func _ready() -> void:
	await get_tree().process_frame
	_initialise()

func _process(_delta: float) -> void:
	if not _initialised:
		_initialise()
		return
	if not is_instance_valid(_camera) and not is_instance_valid(_player):
		_initialised = false
		_death_in_progress = false

func _initialise() -> void:
	var camera := get_tree().current_scene.get_node_or_null("PlayerCamera") as PlayerCamera
	var player := get_tree().current_scene.get_node_or_null("Player")

	if camera == null or player == null:
		return

	_camera = camera
	_player = player
	_initialised = true

	for room in get_tree().get_nodes_in_group("Room"):
		var connections: Array = room.body_entered.get_connections()
		for c in connections:
			room.body_entered.disconnect(c["callable"])
		room.body_entered.connect(_on_room_body_entered.bind(room))

	# If the player died away from the start room, begin the pan-in on the new scene
	if died_away_from_start:
		died_away_from_start = false
		_camera.pan_from(death_room_position)

func is_camera_panning() -> bool:
	if not is_instance_valid(_camera):
		return false
	return _camera.is_room_transition_panning()

func _on_room_body_entered(body: Node2D, room: Area2D) -> void:
	if not body.is_in_group("Player"):
		return
	if is_instance_valid(_camera):
		_camera.go_to_room(room)

func begin_death_sequence() -> void:
	if _death_in_progress or not is_instance_valid(_camera):
		return
	_death_in_progress = true

	var first_room := _get_first_room()
	if first_room == null or first_room == _camera.current_room():
		# Died on room 1, just reload
		get_tree().call_deferred("reload_current_scene")
	else:
		# Store death position so the new scene can pan from it
		death_room_position = _camera.position
		died_away_from_start = true
		get_tree().call_deferred("reload_current_scene")

func _get_first_room() -> Area2D:
	var rooms := get_tree().get_nodes_in_group("Room")
	if rooms.is_empty():
		return null
	var first: Area2D = rooms[0]
	for room: Area2D in rooms:
		if room.global_position.x < first.global_position.x:
			first = room
	return first
