extends Control
class_name CellControl

@export var pokeSearch : LineEdit
@export var categoryController: Control
var cells : Dictionary
var solvedCells = []
var unsolvedCells = []
var searching = false
var ascii_codes = {"A":0,"B":1,"C":2}



func _ready():
	for x in range(1,4):
		for y in range(65,68):
			var cellName = "{0}{1}".format([x,char(y)])
			cells[cellName] = $GridContainer.find_child(cellName)
			cells[cellName].controller = self
			unsolvedCells.append(cells[cellName])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func cell_pressed(cell):
	#print("Cell pressed: %s" %[cell])
	searching = true
	pokeSearch.show()
	pokeSearch.setButton(cells[cell])
	pokeSearch.grab_focus()



func test_pokemon(pokemonName, cell, icon):
	var side = int(str(cell.name)[0])-1
	var top = ascii_codes[str(cell.name)[1]]
	var valid = PokemonData.validate_pokemon(pokemonName, [categoryController.topCategories[top],categoryController.sideCategories[side]])
	if valid:
		cell.set_texture(icon)
		cell.disabled = true
		cell.self_modulate = Color.GREEN
		unsolvedCells.erase(cell)
		solvedCells.append(cell)
		return true
	return false



func _on_texture_button_pressed():
	for c in cells:
		cells[c].set_texture(null)
		cells[c].self_modulate=Color.WHITE
		cells[c].disabled = false
