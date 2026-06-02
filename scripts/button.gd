extends Button

func _ready():
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	$Startclicked.visible = false  # hide sprite initially

func _on_mouse_entered():
	$Startclicked.visible = true

func _on_mouse_exited():
	$Startclicked.visible = false


func _on_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")
	print("pressed 1")
	pass # Replace with function body.
	
func _on_button_2_pressed() -> void:
	get_tree().quit()
	print("pressed 2")
	pass # Replace with function body.
