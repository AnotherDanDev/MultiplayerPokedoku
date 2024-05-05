extends LineEdit

@onready var itemList = $ItemList
@export var cellController:Control
var currentButton :Button = null
var pokemonNames = []


func _ready():
	var pkNames = PokemonData.pokemonDB.select_rows("Pokemon","",["PokemonID","Name","Nat"])
	for p in pkNames:
		pokemonNames.append([p["PokemonID"],p["Name"],p["Nat"]])



func setButton(button):
	currentButton = button

func _on_text_changed(tex):
	if len(text) > 2:
		itemList.clear()
		for p in range(0,len(pokemonNames)):
			var pokeName = pokemonNames[p][1]
			
			if text.to_lower() in pokeName.to_lower():
				var image = Image.new()
				var imageData = PokemonData.pokemonDB.select_rows("PokemonImages", "PokemonID =" + str(pokemonNames[p][0]),["Image"])[0]["Image"]
				image.load_png_from_buffer(imageData)
				itemList.add_item(pokeName,ImageTexture.create_from_image(image))
				



func _on_focus_entered():
	itemList.show()
	self.text = ""


func _on_focus_exited():
	#itemList.hide()
	pass


func _on_item_list_item_selected(index):
	pass
	
func _input(event):
	if has_focus():
		if event is InputEventKey:
			if event.keycode == KEY_DOWN and event.is_pressed():
				itemList.grab_focus()


func _on_item_list_item_clicked(index, at_position, mouse_button_index):
	if mouse_button_index == 1:
		cellController.test_pokemon(itemList.get_item_text(index), currentButton, itemList.get_item_icon(index))
		hide()
		itemList.hide()
		currentButton.grab_focus()
		self.text = ""
