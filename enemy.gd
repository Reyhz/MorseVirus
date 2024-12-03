extends CharacterBody2D

@export var damage = 10: get = get_damage
var dirTo = null: set = set_dir
var speed = 25.0: get = get_speed, set = set_speed

var value = "": get = get_value, set = set_value
@export var scoreValue = 10: get = get_score_value

@export var sprites: Array[CompressedTexture2D] = []

signal ded

# Called when the node enters the scene tree for the first time.
func _ready():
	update_text()
	$Sprite2D.texture = sprites.pick_random()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	velocity = position.direction_to(dirTo) * speed
	move_and_slide()


func set_value(val: String):
	value = val


func set_dir(dir: Vector2):
	dirTo = dir


func set_speed(spd: float):
	speed = spd


func get_speed():
	return speed


func get_damage():
	return damage


func get_value():
	return value


func get_score_value():
	return scoreValue


func is_locked():
	$Sprite2D.material.set_shader_parameter("onoff", 1.0)


# String argument of this method represent a substring of self.Value to highlight
func update_text(substring: String = ""):
	$Text.clear()
	$Text.append_text("[center]")
	if substring:
		$Text.push_color(Color.MIDNIGHT_BLUE)
		$Text.append_text(substring)
		$Text.pop()
	$Text.append_text(value.substr(substring.length()))


func kill():
	queue_free()
	ded.emit()
