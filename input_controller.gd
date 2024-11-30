extends Node

@export var longPressTime = 0.200
var pressTime = 0

signal pressed
signal shortPress
signal longPress(pressedTime)


func _ready():
	pass


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
		get_tree().quit()
