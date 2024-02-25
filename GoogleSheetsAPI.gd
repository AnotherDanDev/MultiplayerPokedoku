extends Node2D

var spreadsheetID = "1ScFZLkP8w4CrkyyFLqSYFFBfJj8LKspyn0Oo1pJiV0g"
var sheetName = "Complete Dex"
var gridID = "821042465"


var pokemonData = {}
func _ready():
	pokemonData = PokemonData.data
	test()
	#matchCategory({"Type I":"Grass"})


var EASY_CATEGORIES = ["Type"]
var MEDIUM_CATEGORIES = ["Rarity", "Evolving at", "Evolved at"]
var HARD_CATEGORIES = ["Egg Group I", "Egg Group II", "Ability I", "Ability II", "Hidden Ability", "Nat", "Org", "Gender"]
var EXTREME_CATEGORIES = ["Catch","EV Worth", "HP", "Atk", "Def", "SpA", "SpD", "Spe","Total"]
var DISCARDED_CATEGORIES = ["Type", "Form"]

var ALL_CATEGORIES = [EASY_CATEGORIES, MEDIUM_CATEGORIES, HARD_CATEGORIES, EXTREME_CATEGORIES]

func test():
	var selectedCategories = [[],[],[]]
	var compCategories = [[],[],[]]
	var COPY_CATEGORIES = ALL_CATEGORIES.duplicate(false)
	var selCat = null
	var selVal = null
	for x in range(0,3):
		var ranNum = randi() % 2
		if len(COPY_CATEGORIES[ranNum]) > 0:
			selCat = COPY_CATEGORIES[ranNum].pick_random()
		else:
			continue
		selVal = PokemonData.dataValues[selCat].pick_random()
		while len(matchCategory({selCat:selVal})) <= 1:
			ranNum = randi() % 2
			selCat = COPY_CATEGORIES[ranNum].pick_random()
			selVal = PokemonData.dataValues[selCat].pick_random()
		if ("Type" not in selCat):
			COPY_CATEGORIES[ranNum].erase(selCat)
		selectedCategories[x].append(selCat)
		selectedCategories[x].append(selVal)
	for x in range(0,3):
		var ranNum = randi() % 2
		var passed = false
		while not passed:
			passed = true
			for y in range(0,3):
				if len(matchCategory({selCat:selVal,selectedCategories[y][0]:selectedCategories[y][1]})) < 1:
					passed = false
			if not passed:
				if len(COPY_CATEGORIES[ranNum]) > 0:
					selCat = COPY_CATEGORIES[ranNum].pick_random()
				else:
					continue
				selVal = PokemonData.dataValues[selCat].pick_random()
		compCategories[x].append(selCat)
		compCategories[x].append(selVal)
		
	print(selectedCategories)
	print()
	print(compCategories)
	print()
	for x in range(0,3):
		var string = ""
		for y in range(0,3):
			var matches = matchCategory({selectedCategories[x][0]:selectedCategories[x][1],compCategories[y][0]:compCategories[y][1]})
			string = string + selectedCategories[x][1] + "/" + compCategories[y][1] + " = " + matches[0] +" "+ str(len(matches)) + "    |||    "
		print(string)
	print("Done")


func matchQuery(category, query):
	var matches = []
	for x in pokemonData[category]:
		if x == query:
			matches.append(x)
	print(matches)

func matchType(type, matches = []):
	for x in range(0,len(pokemonData["Type I"])):
		if pokemonData["Type I"][x] == type:
			matches.append(pokemonData["Pokemon"][x])
	for x in range(0,len(pokemonData["Type II"])):
		if pokemonData["Type I"][x] == type:
			matches.append(pokemonData["Pokemon"][x])
	return matches

func matchTypes(type1,type2):
	var matches = []
	for x in range(0,len(pokemonData["Type I"])):
		if pokemonData["Type I"][x] == type1 or pokemonData["Type I"][x] == type2:
			if pokemonData["Type II"][x] == type1 or pokemonData["Type II"][x] == type2:
				matches.append(pokemonData["Pokemon"][x])
	print(matches)









func matchCategory(query):
	var matches = []
	for x in range(0,len(pokemonData["Pokemon"])):
		var matchFound = true
		var firstType = true
		var ability = true
		for cat in query.keys():
			if not("Ability" in cat or "Type" in cat):
				if pokemonData[cat][x] != query[cat] and not("Type" in cat):
					matchFound = false
			if "Type" in cat:
				if pokemonData["Type I"][x] != query[cat] and pokemonData["Type II"][x] != query[cat]:
					firstType = false
			if "Ability" in cat:
				if query[cat] != pokemonData["Ability I"][x] and query[cat] != pokemonData["Ability II"][x] and query[cat] != pokemonData["Hidden Ability"][x]:
					ability = false
		if matchFound and firstType and ability:
			matches.append(pokemonData["Pokemon"][x])
	return matches
	#print(matches)







