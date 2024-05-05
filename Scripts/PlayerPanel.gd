extends Panel

var first_names = ["Pich", "Amir", "Kosan", "Soft", "Pie", "Goog", "Alex", "GubGub"]

# Called when the node enters the scene tree for the first time.
func _ready():
	PokemonData.pokemonDB.query("SELECT PokemonID FROM Pokemon ORDER BY RANDOM() LIMIT 1;")
	var pokemon = PokemonData.pokemonDB.query_result[0]["PokemonID"]
	var imageData = PokemonData.pokemonDB.select_rows("PokemonImages","PokemonID = %s" % [pokemon],["Image"])
	imageData = imageData[0]["Image"]
	var image = Image.new()
	image.load_png_from_buffer(imageData)
	var texture = ImageTexture.create_from_image(image)
	$TextureRect.texture = ImageTexture.create_from_image(image)
	var child = find_children("AnimationPlayer")
	if len(child) > 0:
		child[0].play("FakeReady")
	
	if $PlayerName.text == "Player":
		$PlayerName.text = first_names.pick_random()
	
	PlayerManager.players.append([$PlayerName.text,texture])

# Called every frame. 'delta' is the elapsed time since the previous frame.

func _on_check_box_toggled(toggled_on):
	if toggled_on:
		PlayerManager.ready_player(1)
	else:
		PlayerManager.ready_player(-1)
