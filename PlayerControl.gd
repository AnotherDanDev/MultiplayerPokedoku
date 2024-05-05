extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("Add Players")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass





func _on_timer_timeout():
	var random = PlayerManager.playerPuzzles.slice(1,len(PlayerManager.playerPuzzles))
	random = random.pick_random()
	random.solve_cell()
	


	
