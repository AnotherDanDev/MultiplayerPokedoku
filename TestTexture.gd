extends TextureRect


# Called when the node enters the scene tree for the first time.
func _ready():
	var p = PokemonData.random_pokemon()
	var image = Image.new()
	image.load_png_from_buffer(p["Image"])
	texture = ImageTexture.create_from_image(image)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
