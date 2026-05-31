extends Camera2D
var player_node
@export var follow_smoothing: float = 0.1
var smoothing: float
var current_room: Area2D
var furthest_room: Area2D
var respawn_position: Vector2
@onready var view_size: Vector2 = get_viewport_rect().size
var zoom_view_size: Vector2
var needs_snap: bool = false

func _ready() -> void:
	position_smoothing_enabled = false
	smoothing = 0.05  # slow pan
	await get_tree().create_timer(1.0).timeout
	smoothing = follow_smoothing

func _physics_process(delta: float) -> void:
	if player_node == null:
		player_node = get_tree().get_first_node_in_group("Player")
		return

	for room in get_tree().get_nodes_in_group("Room"):
		var shape = room.get_node("CollisionShape2D")
		var room_rect = shape.shape.get_rect()
		var room_global_rect = Rect2(shape.global_position - room_rect.size / 2 - Vector2(2, 2), room_rect.size + Vector2(4, 4))
		if room_global_rect.has_point(player_node.global_position):
			if current_room != room:
				current_room = room
				if furthest_room == null or room.global_position.x > furthest_room.global_position.x:
					furthest_room = room
					respawn_position = player_node.global_position
			break

	if current_room == null:
		return

	var shape = current_room.get_node("CollisionShape2D")
	var room_rect = shape.shape.get_rect()
	var room_center = shape.global_transform * room_rect.get_center()

	if needs_snap:
		position = room_center
		needs_snap = false
	else:
		position = lerp(position, room_center, smoothing)

func snap_to_room():
	needs_snap = true
