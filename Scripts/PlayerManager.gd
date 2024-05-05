extends Node


var players = []
var readyPlayers = 0
var playerPuzzles = []

func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func ready_player(x):
	readyPlayers += x
	if readyPlayers == 4:
		print("start")
		get_tree().change_scene_to_file("res://Main.tscn")
