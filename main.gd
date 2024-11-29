extends Node2D

@export var longPress = 0.200 # Time in millisecond to consider input as a Dash
var pressTime = 0

@export var mobScene: PackedScene
@onready var player = $Player
var health = 100: get = get_health, set = set_health

var maxEnemies = 20
var currEnemies = 0

var locked = false
var lockedEnemy = null
var lockedValue = null
var currValue = ""

var morseValues = {
	"A": ".-",
	"B": "-...",
	"C": "-.-.",
	"D": "-..",
	"E": ".",
	"F": "..-.",
	"G": "--.",
	"H": "....",
	"I": "..",
	"J": ".---",
	"K": "-.-",
	"L": ".-..",
	"M": "--",
	"N": "-.",
	"O": "---",
	"P": ".--.",
	"Q": "--.-",
	"R": ".-.",
	"S": "...",
	"T": "-",
	"U": "..-",
	"V": "...-",
	"W": ".--",
	"X": "-..-",
	"Y": "-.--",
	"Z": "--.."
}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):	
	if currEnemies >= maxEnemies:
		$MobSpawn.paused = true
	elif currEnemies < maxEnemies:
		$MobSpawn.paused = false
	
	if not locked:
		lockedEnemy = _get_closest_enemy()
		if lockedEnemy:
			locked = true
			lockedValue = lockedEnemy.value
			lockedEnemy.is_locked()
	elif locked:
		if Input.is_action_pressed("CHOSEN_ONE"):
			pressTime += delta
		
		if Input.is_action_just_released("CHOSEN_ONE"):
			# TODO: Refactor this code ( method to check if next val is the right one ? )
			if pressTime > longPress:
				if lockedValue[currValue.length()] == "-":
					currValue += "-"
			else:
				if lockedValue[currValue.length()] == ".":
					currValue += "."
			lockedEnemy.update_text(currValue)
			pressTime = 0
		
		if currValue == lockedValue:
			kill_enemy(lockedEnemy)


func get_health():
	return health


func set_health(value):
	health = value


func kill_enemy(enemy: Node2D):
	enemy.kill()
	# If locked enemy was killed, we no longer lock it to allow locking a new valid enemy
	if enemy == lockedEnemy:
		locked = false
		currValue = ""


func damage_player(damage):
	health -= damage
	if(health <= 0):
		# TODO: Game Over Screen
		pass


func _get_closest_enemy():
	var enemyList = get_tree().get_nodes_in_group("enemy")
	var closestMob = null
	var distance = (1 << 31) - 1 # max int32 Value because we try to find the closest enemy
	for enemy in enemyList:
		var distToEnemy = enemy.global_position.distance_to(player.global_position)
		if distToEnemy < distance:
			distance = distToEnemy
			closestMob = enemy
	return closestMob


func _on_mob_spawn_timeout():
	var spawnPoint = $Spawner/PathFollow2D
	spawnPoint.progress_ratio = randf()
	
	var mob = mobScene.instantiate()
	mob.position = spawnPoint.global_position
	mob.speed = randf_range(15.0, 50.0)
	mob.dirTo = player.position
	mob.value = morseValues[morseValues.keys().pick_random()]
	mob.ded.connect(_on_mob_ded)
	
	add_child(mob)
	currEnemies += 1


func _on_area_2d_body_entered(body):
	if body.is_in_group("enemy"):
		damage_player(body.damage)
		kill_enemy(body)


func _on_mob_ded():
	currEnemies -= 1
