extends Node

@export var longPressTime = 0.200
var pressTime = 0
var highScore = 0

signal pressed
signal shortPress
signal longPress(pressedTime)


func _ready():
	var config = ConfigFile.new()
	var loaded = config.load("user://data.reyhz")
	var created = false
	
	if loaded == ERR_FILE_NOT_FOUND:
		config.set_value("GAME", "High Score", highScore)
		config.save("user://data.reyhz")
	
	if !created:
		highScore = config.get_value("GAME", "High Score")


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
		config.save("user://data.reyhz")
		get_tree().quit()
