extends Panel


@onready var cellController = $CellController
@onready var categoryController = $CategoryController

func _ready():
	var player:Array = PlayerManager.players.pop_front()
	add_player_data(player[0], player[1])
	PlayerManager.playerPuzzles.append(self)
	modulate = Color(255,255,255,0)
	$LoadIn.play("LoadIn")


func add_player_data(playerName, image):
	$PlayerName.text = playerName
	$"Player Profile".texture = image

func _process(delta):
	pass

func solve_cell():
	var cell = cellController.unsolvedCells.pick_random()
	var side = int(str(cell.name)[0])-1
	var top = cellController.ascii_codes[str(cell.name)[1]]
	var pokemon = PokemonData.random_pokemon([categoryController.topCategories[top],categoryController.sideCategories[side]])
	var image = Image.new()
	var imageData = PokemonData.pokemonDB.select_rows("PokemonImages", "PokemonID =" + str(pokemon["PokemonID"]),["Image"])[0]["Image"]
	image.load_png_from_buffer(imageData)
	cellController.test_pokemon(pokemon["Name"], cell,ImageTexture.create_from_image(image))
	
	
	
