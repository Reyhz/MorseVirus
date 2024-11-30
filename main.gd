extends Node

@export var longPress = 0.200 # Time in millisecond to consider input as a Dash
var pressTime = 0

@export var mobScene: PackedScene
@onready var player = $Player
var health = 10: get = get_health, set = set_health
var score = 0: get = get_score
var gameTime = 0

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

# TODOLIST: 
# Tutorial window for first time player --> button to access it if player forgor
# Diffculty setting --> More enemy / Higher Speed / More complex words ?
# WARNING Don't forget to do textures, and sound if time allows it ( only 2d left )
# More mechanics ( if time allows it ) --> powerups, roguelike ( lol ?), deckbuilding ( wth reyhz? )


# Called when the node enters the scene tree for the first time.
func _ready():
	InputController.longPress.connect(_on_long_press)
	InputController.shortPress.connect(_on_short_press)
	$Hud.update_score(score)


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
		if currValue == lockedValue:
			kill_enemy(lockedEnemy)


func get_health():
	return health


func get_score():
	return score


func set_health(value):
	health = value


func add_score(toAdd):
	score += toAdd
	$Hud.update_score(score)


func kill_enemy(enemy: Node2D):
	enemy.kill()
	# If locked enemy was killed, we no longer lock it to allow locking a new valid enemy
	if enemy == lockedEnemy:
		locked = false
		currValue = ""
		add_score(enemy.scoreValue)


func damage_player(damage):
	health -= damage
	if(health <= 0):
		game_over()


func game_over():
	# TODO: if time allows it make different game over texts !
	$Hud/%TimeSurvived.text += $Hud.convert_time(int($Hud.gameTime))
	$Hud/%Score.text += str(score)
	$Hud/%HighScore.text = "." # TODO: HighScore value
	$Hud/GameOverController.show()
	
	await InputController.pressed
	get_tree().change_scene_to_file("res://menu.tscn")


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


func _on_timer_timeout():
	add_score(1)


func _on_short_press():
	if lockedValue[currValue.length()] == "." && locked:
		currValue += "."
		lockedEnemy.update_text(currValue)


func _on_long_press(pressedTime):
	if pressedTime >= 0.750:
		$Hud/PauseContainer.show()
		get_tree().paused = true
	elif lockedValue[currValue.length()] == "-" && locked:
		currValue += "-"
		lockedEnemy.update_text(currValue)
