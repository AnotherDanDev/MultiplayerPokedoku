extends Control

var database : SQLite


# Called when the node enters the scene tree for the first time.
func _ready():
	database = SQLite.new()
	database.path = "res://Pokemon Data/PokemonDB.db"
	database.open_db()
	pass
	var r = database.select_rows("Pokemon", "Name = 'Bulbasaur'",["Name"])
	print(r)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
