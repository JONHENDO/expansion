extends Button

func _ready():
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	$Quitclicked.visible = false  # hide sprite initially

func _on_mouse_entered():
	$Quitclicked.visible = true

func _on_mouse_exited():
	$Quitclicked.visible = false
