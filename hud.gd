extends Control

var gameTime = 0
var gameOver = false

# Called when the node enters the scene tree for the first time.
func _ready():
	%Exit.text = %Exit.text.replace("BUTTON", InputController.keybind.as_text().trim_suffix(" (Physical)"))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Background/Time.text = Time.get_time_string_from_system().left(-3)
	if !get_tree().paused && !gameOver:
		gameTime += delta
		%Time.text = convert_time(int(gameTime))


func convert_time(time: int):
	var seconds = time % 60
	@warning_ignore("integer_division") # Shut up editor I don't care about decimal part
	var minutes = (time / 60) % 60

	return "%02d:%02d" % [minutes, seconds]


func update_score(score: int):
	%ScoreHud.text = "SCORE : %06d" % score


func update_combo(mutliplier: int, timeLeft: float):
	%Multiplier.text = "Multiplier : " + str(mutliplier) + "x"
	$MultPanel/TimeLeft.value = timeLeft


func update_hp(health: int):
	%HP.text = "HP : " + str(health)
