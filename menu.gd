extends Control

var buttonsArray = null
var index = 0
var selected = null

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().paused = false # We unpause the tree here in case the last scene was paused
	InputController.shortPress.connect(_on_short_press)
	InputController.longPress.connect(_on_long_press)
	
	buttonsArray = $Buttons.get_children(true)
	selected = buttonsArray[index]
	selected.grab_focus()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_short_press():
	index += 1
	selected = buttonsArray[index % buttonsArray.size()]
	selected.grab_focus()


func _on_long_press(pressTime):
	button_handler(selected)


func button_handler(button: Button):
	match button.name:
		"Play":
			get_tree().change_scene_to_file("res://main.tscn")
		"Settings":
			print_debug("SETTINGS")
		"Quit":
			get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
