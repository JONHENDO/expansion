extends Area2D

const GRACE_PERIOD: float = 0.2
var _active: bool = false

func _ready() -> void:
	_active = false
	await get_tree().create_timer(GRACE_PERIOD).timeout
	_active = true

func _on_body_entered(body: Node2D) -> void:
	if not _active:
		return
	if body.is_in_group("Player"):
		_active = false
		body.die()
		Global.begin_death_sequence()
