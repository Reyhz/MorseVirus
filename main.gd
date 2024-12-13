extends Node

@export var longPress = 0.200 # Time in millisecond to consider input as a Dash
var pressTime = 0

@export var mobScene: PackedScene
@onready var player = $Player
var health = 50: get = get_health, set = set_health
var score = 0: get = get_score
var gameTime = 0

var maxEnemies = 30
var currEnemies = 0

var locked = false
var lockedEnemy = null
var lockedValue = null
var currValue = ""

var multiplier = 1
var comboTime = 2.0
var inCombo = false

var speedModifier = 1.00

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
# Sound design
# Better graphics --> maybe hire artist ?
# More mechanics --> powerups, roguelike, deckbuilding ?


# Called when the node enters the scene tree for the first time.
func _ready():
	InputController.longPress.connect(_on_long_press)
	InputController.shortPress.connect(_on_short_press)
	$Hud.update_score(score)
	$Hud.update_hp(health)
	reset_combo()


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
	
	if inCombo:
		comboTime -= delta
		$Hud.update_combo(multiplier, comboTime)
		if comboTime <= 0:
			reset_combo()


func get_health():
	return health


func get_score():
	return score


func set_health(value):
	health = clamp(value, 0, 50)


func add_score(toAdd):
	score += toAdd * multiplier
	$Hud.update_score(score)


func combo_handler():
	if !inCombo:
		inCombo = true
		$Hud/MultPanel.show()
	
	multiplier = multiplier + 1 if multiplier < 5 else multiplier
	comboTime += 1.2 - (0.1 * (multiplier - 1))
	$Hud.update_combo(multiplier, comboTime)


func reset_combo():
	$Hud/MultPanel.hide()
	inCombo = false
	multiplier = 1
	comboTime = 2.0


func kill_enemy(enemy: Node2D, playerHit: bool = false):
	enemy.kill()
	# If locked enemy was killed, we no longer lock it to allow locking a new valid enemy
	if enemy == lockedEnemy:
		locked = false
		currValue = ""
		if !playerHit: 
			add_score(enemy.scoreValue)
			combo_handler()


func damage_player(damage):
	health -= damage
	$Hud.update_hp(health)
	if(health <= 0):
		game_over()


func game_over():
	# TODO: if time allows it make different game over texts !
	InputController.highScore = max(InputController.highScore, score)
	locked = false
	$Hud.gameOver = true
	$MobSpawn.stop()
	$Timer.stop()
	get_tree().call_group("enemy","queue_free")
	$Hud/%TimeSurvived.text += $Hud.convert_time(int($Hud.gameTime))
	$Hud/%Score.text += str(score)
	$Hud/%HighScore.text += str(InputController.highScore)
	$Hud/GameOverController.show()
	
	await get_tree().create_timer(1.0).timeout
	await InputController.pressed
	get_tree().change_scene_to_file("res://menu.tscn")


func _get_closest_enemy():
	var enemyList = get_tree().get_nodes_in_group("enemy")
	var closestMob = null
	var distance = (1 << 31) - 1 # max int32 Value because we try to find the closest enemy
	for enemy in enemyList:
		var distToEnemy = enemy.global_position.distance_to(player.global_position)
		if distToEnemy <= distance:
			distance = distToEnemy
			closestMob = enemy
	return closestMob


func _on_mob_spawn_timeout():
	var spawnPoint = $Spawner/PathFollow2D
	spawnPoint.progress_ratio = randf()
	
	var mob = mobScene.instantiate()
	mob.position = spawnPoint.global_position
	mob.speed = randf_range(25.0, 40.0) * speedModifier
	mob.dirTo = player.position
	mob.value = morseValues[morseValues.keys().pick_random()]
	mob.ded.connect(_on_mob_ded)
	
	add_child(mob)
	currEnemies += 1


func _on_area_2d_body_entered(body):
	if body.is_in_group("enemy"):
		damage_player(body.damage)
		kill_enemy(body, true)


func _on_mob_ded():
	currEnemies -= 1


func _on_timer_timeout():
	add_score(1)


func _on_short_press():
	if locked && lockedValue[currValue.length()] == ".":
		currValue += "."
		lockedEnemy.update_text(currValue)


func _on_long_press(pressedTime):
	if pressedTime >= InputController.longPressTime + 0.500:
		$Hud/PauseContainer.show()
		get_tree().paused = true
	elif locked && lockedValue[currValue.length()] == "-":
		currValue += "-"
		lockedEnemy.update_text(currValue)


func _on_difficulty_timer_timeout():
	if $MobSpawn.wait_time > 0.50:
		$MobSpawn.wait_time -= 0.10
	speedModifier += 0.05
