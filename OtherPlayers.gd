extends VBoxContainer

var fakePlayerPuzzle = preload("res://FakePlayerPuzzle.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func add_player():
	add_child(fakePlayerPuzzle.instantiate())
