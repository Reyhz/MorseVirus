extends Node2D

@export var longPress = 0.03
var pressTime = 0

@export var mobScene: PackedScene
@onready var player = $Player
var health = 100: get = get_health, set = set_health

var maxEnemies = 2
var currEnemies = 0

var locked = false
var lockedEnemy = null

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
	if Input.is_action_pressed("CHOSEN_ONE"):
		pressTime += delta
	
	if currEnemies >= maxEnemies:
		$MobSpawn.paused = true
	elif currEnemies < maxEnemies:
		$MobSpawn.paused = false
	
	if not locked:
		lockedEnemy = _get_closest_enemy()
		if lockedEnemy:
			locked = true
	elif locked:
		# TODO: Enemy is selected, player need to enter the morse value of the enemy to kill it
		# Once that is done give score to player then set locked to false and lockedenemy to null
		# Next frame a new enemy will get locked on
		#
		# TODO: Handle input, the only button to play this game
		pass


func get_health():
	return health


func set_health(value):
	health = value


func damage_player(damage):
	health -= damage
	if(health <= 0):
		# TODO: Game Over Screen
		pass


func _get_closest_enemy():
	var enemyList = get_tree().get_nodes_in_group("enemy")
	var closestMob = null
	var distance = (1 << 31) - 1 # max int32 value shouldn't need more
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
	
	add_child(mob)
	currEnemies += 1


func _on_area_2d_body_entered(body):
	if body.is_in_group("enemy"):
		damage_player(body.damage)
		body.kill()
		currEnemies -= 1
