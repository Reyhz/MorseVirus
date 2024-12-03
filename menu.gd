extends Control

var buttonsArray = null
var index = 0
var selected = null

var isRemapping = false

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().paused = false # We unpause the tree here in case the last scene was paused
	InputController.shortPress.connect(_on_short_press)
	InputController.longPress.connect(_on_long_press)
	
	buttonsArray = %MainMenu.get_children(true)
	buttonsArray.remove_at(0)
	selected = buttonsArray[index]
	selected.grab_focus()
	
	%Keybind.text = "ACTION BUTTON : " + InputController.keybind.as_text().trim_suffix(" (Physical)")
	%LongPressTime.text = "LONG PRESSTIME : " + str(int((InputController.longPressTime * 1000.0))) + "ms"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_short_press():
	index += 1
	selected = buttonsArray[index % buttonsArray.size()]
	selected.grab_focus()


func _on_long_press(_pressTime):
	button_handler(selected)


func button_handler(button: Button):
	match button.name:
		"Play":
			get_tree().change_scene_to_file("res://main.tscn")
		"Settings":
			%MainMenu.hide()
			%SettingsWindow.show()
			
			buttonsArray = %SettingsWindow.get_children(true)
			buttonsArray.remove_at(0)
			_on_short_press()
		"Quit":
			get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
		"Keybind":
			if not isRemapping:
				isRemapping = true
				%Keybind.text = "ACTION BUTTON : Press any Key..."
		"LongPressTime":
			InputController.longPressTime = wrapf(InputController.longPressTime + 0.100, 0.100, 0.700)
			%LongPressTime.text = "LONG PRESSTIME : " + str(int((InputController.longPressTime * 1000.0))) + "ms"
		"MainMenuButton":
			%MainMenu.show()
			%SettingsWindow.hide()
			
			buttonsArray = %MainMenu.get_children(true)
			buttonsArray.remove_at(0)
			_on_short_press()


func _input(event):
	if isRemapping:
		if event is InputEventKey or (event is InputEventMouseButton && event.pressed):
			InputMap.action_erase_events("CHOSEN_ONE")
			InputMap.action_add_event("CHOSEN_ONE",event)
			
			if event is InputEventMouseButton && event.double_click:
				event.double_click = false
			
			isRemapping = false
			%Keybind.text = "ACTION BUTTON : " + event.as_text().trim_suffix(" (Physical)")
			InputController.keybind = event
			accept_event()
