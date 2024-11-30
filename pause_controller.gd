extends PanelContainer

var longPressTime = InputController.longPressTime
var pressTime = 0

var index = 0
var buttonArray = null
var selected = null

# Called when the node enters the scene tree for the first time.
func _ready():
	buttonArray = [%Resume, %Settings, %MainMenu]
	selected = buttonArray[index]
	selected.grab_focus()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("CHOSEN_ONE"):
		pressTime += delta
	
	if Input.is_action_just_released("CHOSEN_ONE"):
		if pressTime >= 0.750:
			self.hide()
			get_tree().paused = false
		elif pressTime >= longPressTime:
			button_handler(selected)
		else:
			index += 1
			selected = buttonArray[index % buttonArray.size()]
			selected.grab_focus()
		
		pressTime = 0


func button_handler(button: Button):
	match button.name:
		"Resume":
			get_tree().paused = false
			self.hide()
		"Settings":
			print_debug("SETTINGS")
		"MainMenu":
			get_tree().change_scene_to_file("res://menu.tscn")
