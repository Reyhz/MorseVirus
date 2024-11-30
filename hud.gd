extends Control

var gameTime = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !get_tree().paused:
		gameTime += delta
		%Time.text = convert_time(int(gameTime))


func convert_time(time: int):
	var seconds = time % 60
	@warning_ignore("integer_division") # Shut up editor I don't care about decimal part
	var minutes = (time / 60) % 60
	
	return "%02d:%02d" % [minutes, seconds]


func update_score(score: int):
	%ScoreHud.text = "SCORE : %07d" % score
