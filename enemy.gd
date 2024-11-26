extends CharacterBody2D

@export var damage = 10: get = get_damage
var dirTo = null: set = set_dir
var speed = 25.0: get = get_speed, set = set_speed

var text = ""


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	velocity = position.direction_to(dirTo) * speed
	move_and_slide()


func set_dir(dir):
	dirTo = dir


func set_speed(spd):
	speed = spd


func get_speed():
	return speed


func get_damage():
	return damage


func kill():
	queue_free()
