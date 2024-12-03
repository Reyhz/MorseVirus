extends Node

@export var longPressTime = 0.200
var pressTime = 0
var highScore = 0

var keybind = null

signal pressed
signal shortPress
signal longPress(pressedTime)


func _ready():
	var config = ConfigFile.new()
	var loaded = config.load("user://data.reyhz")
	
	# Setting file does not exist so we save the default value
	if loaded == ERR_FILE_NOT_FOUND:
		config.set_value("GAME", "High Score", highScore)
		config.set_value("GAME", "CHOSEN ONE", InputMap.action_get_events("CHOSEN_ONE"))
		config.set_value("GAME", "Long Press Time", longPressTime)
		config.save("user://data.reyhz")
		return
	
	# Setting file does exist so we set the values accordingly
	highScore = config.get_value("GAME", "High Score")
	longPressTime = config.get_value("GAME", "Long Press Time")
	_load_keybind(config)


func _process(delta):
	if Input.is_action_pressed("CHOSEN_ONE"):
		pressTime += delta
	
	if Input.is_action_just_released("CHOSEN_ONE"):
		pressed.emit()
		if pressTime >= longPressTime:
			print_debug("LONGPRESS // " + str(pressTime))
			longPress.emit(pressTime)
		else:
			shortPress.emit()
			print_debug("SHORTPRESS")
		
		pressTime = 0


func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		var config = ConfigFile.new()
		config.load("user://data.reyhz")
		config.set_value("GAME", "High Score", highScore)
		config.set_value("GAME", "CHOSEN ONE", keybind)
		config.set_value("GAME", "Long Press Time", longPressTime)
		config.save("user://data.reyhz")
		get_tree().quit()


func _load_keybind(config: ConfigFile):
	if config.has_section_key("GAME", "CHOSEN ONE"):
		keybind = config.get_value("GAME", "CHOSEN ONE")
		InputMap.action_erase_events("CHOSEN_ONE")
		InputMap.action_add_event("CHOSEN_ONE", keybind)
	else:
		keybind = InputMap.action_get_events("CHOSEN_ONE")[0]
	

