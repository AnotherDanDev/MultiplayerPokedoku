extends Node


var data = {}
var categories = []
var dataValues = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	import_resource_data()
	get_data_values()


func import_resource_data():
	var example_dict = {}
	var file = FileAccess.open("res://Pokemon Data/Pokemon Data.txt",FileAccess.READ)
	while !file.eof_reached():
		var data_set = Array(file.get_csv_line())
		example_dict[example_dict.size()] = data_set
	for x in example_dict.keys():
		data[example_dict[x][0]] = example_dict[x].slice(1,len(example_dict[x]))
	categories = data.keys()

func get_data_values():
	for x in data.keys():
		dataValues[x] = []
		for y in data[x]:
			if y not in dataValues[x]:
				dataValues[x].append(y)

func get_types():
	pass

