extends LineEdit

@onready var itemList = $ItemList
var currentButton :Button = null

func _ready():
	pass # Replace with function body.



func setButton(button):
	print(button)
	currentButton = button

func _on_text_changed(tex):
	if len(text) > 2:
		itemList.clear()
		for p in range(0,len(PokemonData.data["Pokemon"])):
			var pokeName = PokemonData.data["Pokemon"][p]
			var pokeDex = str(PokemonData.data["Nat"][p]).pad_zeros(4)
			var pDex = pokeDex.split(".")
			if len(pDex) > 1:
				pokeDex = pDex[0]+"_"+pDex[1].pad_zeros(2)
			
			if text.to_lower() in pokeName.to_lower():
				var texture = load("res://Sprites/"+pokeDex+".png")
				itemList.add_item(pokeName,texture)
				



func _on_focus_entered():
	itemList.show()


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


func _on_item_list_item_activated(index):
	currentButton.set_texture(itemList.get_item_icon(index))
	hide()
	itemList.hide()
	currentButton.grab_focus()
