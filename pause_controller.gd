extends PanelContainer

var longPressTime = InputController.longPressTime
var pressTime = 0

var index = 0
var buttonArray = null
var selected = null

var isRemapping = false

# Called when the node enters the scene tree for the first time.
func _ready():
	_default_pause_behaviour()
	%Keybind.text = "ACTION BUTTON : " + InputController.keybind.as_text().trim_suffix(" (Physical)")
	%LongPressTime.text = "LONG PRESSTIME : " + str(int((InputController.longPressTime * 1000.0))) + "ms"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("CHOSEN_ONE"):
		pressTime += delta
	
	if Input.is_action_just_released("CHOSEN_ONE"):
		if pressTime >= longPressTime + 0.500:
			self.hide()
			_default_pause_behaviour()
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
			%SettingsMenu.visible = not %SettingsMenu.visible
			%MainPause.visible = not %MainPause.visible
			
			buttonArray = [%Keybind, %LongPressTime, %Back]
			selected = buttonArray[index % buttonArray.size()]
			selected.grab_focus()
		"MainMenu":
			get_tree().change_scene_to_file("res://menu.tscn")
		"Keybind":
			if not isRemapping:
				isRemapping = true
				%Keybind.text = "ACTION BUTTON : Press any Key..."
		"LongPressTime":
			InputController.longPressTime = wrapf(InputController.longPressTime + 0.100, 0.100, 0.700)
			%LongPressTime.text = "LONG PRESSTIME : " + str(int((InputController.longPressTime * 1000.0))) + "ms"
		"Back":
			_default_pause_behaviour()


func _default_pause_behaviour():
	buttonArray = [%Resume, %Settings, %MainMenu]
	selected = buttonArray[index % buttonArray.size()]
	selected.grab_focus()
	
	%MainPause.show()
	%SettingsMenu.hide()


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
