extends CharacterBody2D

@export var damage = 10: get = get_damage
var dirTo = null: set = set_dir
var speed = 25.0: get = get_speed, set = set_speed

var value = "": get = get_value, set = set_value


signal ded

# Called when the node enters the scene tree for the first time.
func _ready():
	$Text.text = value


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	velocity = position.direction_to(dirTo) * speed
	move_and_slide()


func set_value(val: String):
	value = val


func set_dir(dir):
	dirTo = dir


func set_speed(spd):
	speed = spd


func get_speed():
	return speed


func get_damage():
	return damage


func get_value():
	return value


func is_locked():
	# TODO : Make the enemy glow ? or at least make it seen for the player
	pass


func kill():
	queue_free()
	ded.emit()
