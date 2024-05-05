extends Node

var pokemonDB : SQLite

var currentCategories = []
var currentCategoryAnswers : Dictionary
var difficulty = 1
@onready var random = RandomNumberGenerator.new()

#Final Evolution Category
#Original Route Category

var EASY_CATEGORIES = ["Type1","Type2","Rarity"]
var MEDIUM_CATEGORIES = ["Form", "Region"]
var HARD_CATEGORIES = ["EggGroup1", "EvolvingAt", "EvolvedAt", "EggGroup2", "Ability1", "Ability2", "HiddenAbility", "Nat", "Org", "Gender"]
var EXTREME_CATEGORIES = ["Catch","EVWorth", "HP", "Atk", "Def", "SpA", "SpD", "Spe","StatTotal"]


#var DISCARDED_CATEGORIES = ["Type", "Form"]
var ALL_CATEGORIES = [EASY_CATEGORIES, MEDIUM_CATEGORIES, HARD_CATEGORIES, EXTREME_CATEGORIES]
var validFirstCategories = ["Type1","Type2","Rarity","EvolvingAt", "EvolvedAt","Region","EggGroup1", "EggGroup2"]

var NULL_ALLOWED_CATEGORIES = ["EvolvingAt","EvolvedAt"]

var outlawedTopCategories:Array[PokemonData.Category] = [Category.new("Type2",null)]
var outlawedSideCategories:Array[PokemonData.Category] = [Category.new("Type1",null)]

#var topCats:Array[Category] = []
#var sideCats:Array[Category] = []




func _ready():
	random.randomize()
	pokemonDB = SQLite.new()
	pokemonDB.path = "res://Pokemon Data/PokemonDB.db"
	pokemonDB.open_db()
	
	setup_categories()
	setup_answers()
	
	
	#var rando = random_pokemon([["Type1","Grass"]])
	#print(validate_pokemon(rando, [["Type1","Grass"],["Type2","Water"]]))
	#print(rando)
	#validate_pokemon(rando,[])

func setup_categories():
	var categories = []
	for x in range(0,difficulty):
		for c in ALL_CATEGORIES[x]:
			categories.append(c)
	currentCategories = categories
	var firstCats = []
	for c in categories:
		if c in validFirstCategories:
			firstCats.append(c)
	validFirstCategories = firstCats
func setup_answers():
	for c in currentCategories:
		pokemonDB.query("SELECT DISTINCT %s FROM Pokemon;" % [c])
		var answers = pokemonDB.query_result.map(func(x): return x.values()[0])
		currentCategoryAnswers[c] = []
		for a in answers:
			var answer = a
			if a == null:
				if c in NULL_ALLOWED_CATEGORIES:
					answer = "NULL"
					pokemonDB.query('SELECT COUNT(*) AS SUM FROM Pokemon WHERE %s is %s;' % [c,answer])
				else:
					continue
			else:
				pokemonDB.query('SELECT COUNT(*) AS SUM FROM Pokemon WHERE %s = "%s";' % [c,answer])
			var queryResult = pokemonDB.query_result[0]["SUM"]
			if queryResult > 3:
				currentCategoryAnswers[c].append([answer,queryResult])

func select_categories():
	var attempt = null;
	while attempt == null:
		attempt = attempt_categories()
	return attempt

func attempt_categories():
	var topCats:Array[Category] = []
	var sideCats:Array[Category] = []
	for x in range(0,3):
		var attempt1 = get_random_target(sideCats, outlawedTopCategories, topCats)
		if attempt1 == null:
			return null
		topCats.append(attempt1)
		var attempt2 = get_random_target(topCats, outlawedSideCategories, sideCats)
		if attempt2 == null:
			return null
		sideCats.append(attempt2)
	return [topCats, sideCats]

func verify_categories(topCats, sideCats):
	for x in range(0,3):
		for y in range(0,3):
			var p = get_valid_pokemon([topCats[x],sideCats[y]])
			if p:
				print_rich("Cell[%s,%s] is [color=GREEN]valid[/color]" %[topCats[x].target,sideCats[y].target])
			else:
				print_rich("Cell[%s,%s] is [color=RED]invalid[/color]" %[topCats[x].target,sideCats[y].target])


func get_random_target(blacklistCategories:Array[Category] = [], invalidCategories:Array[Category] = [], adjacentTargets:Array[Category] = [], timeOutAttempts = 10):
	var categories = currentCategories.duplicate()
	if len(blacklistCategories) == 0:
		categories = validFirstCategories.duplicate()
	var validCat
	var validAnswer = null
	var validPokemon = null
	for b in blacklistCategories + invalidCategories:
		categories.erase(b.category)
	var blacklistedAnswers = []
	for a in adjacentTargets + blacklistCategories:
		if a.target == null:
			continue
		blacklistedAnswers.append(a.target)
	
	var valid = false
	var count = 0
	
	while valid == false:
		valid = true
		validCat = categories[random.randi_range(0,len(categories)-1)]
		validPokemon = random_pokemon_answer(validCat, blacklistedAnswers)
		if validPokemon == null:
			continue
		validAnswer = validPokemon[validCat]
		for x in range(0,len(blacklistCategories)):
			if not get_valid_pokemon([blacklistCategories[x],Category.new(validCat, validPokemon[validCat])]):
				#print_rich("[color=RED]INVALID[/color]")
				valid = false
				count += 1
				break
		if count >= timeOutAttempts:
			#print_rich("[color=RED]INVALID SEQUENCE RESTARTING[/color]")
			return null
	#print_rich("Valid Category: [color=GREEN]%s[/color]/[color=GREEN]%s[/color] Pokemon: [color=GREEN]%s[/color]" % [validCat,validAnswer, validPokemon["Name"]])
	return Category.new(validCat, validAnswer)
	
func random_pokemon_answer(category, blacklistedAnswers = [], opposingCategory:Category = null):
	#print(blacklistedAnswers)
	var answerString = current_answers_string(category, blacklistedAnswers)
	var queryStr = ""
	if opposingCategory == null:
		queryStr ="Select * From Pokemon WHERE %s IN %s ORDER BY RANDOM() LIMIT 1;" % [category,answerString]
	else:
		queryStr ='Select * From Pokemon WHERE %s IN %s AND %s = "%s" ORDER BY RANDOM() LIMIT 1;' % [category,answerString, opposingCategory.category, opposingCategory.target]

	#print(queryStr)
	pokemonDB.query(queryStr)
	if len(pokemonDB.query_result) < 1:
		return null
	else:
		return pokemonDB.query_result[0]

func get_valid_pokemon(categories):
	var queryStr = 'SELECT * FROM Pokemon WHERE %s;' % [get_category_string(categories)]
	#print_rich("[color=YELLOW]QUERY TEST:[/color] %s" % [queryStr])
	pokemonDB.query(queryStr)
	if len(pokemonDB.query_result) >= 1:
		return true
	else:
		return false

func current_answers_string(category, blacklistedAnswers = []):
	var answerString = "("
	var lastAnswer = currentCategoryAnswers[category][currentCategoryAnswers[category].size()-1]
	for a in currentCategoryAnswers[category]:
		if a[0] in blacklistedAnswers:
			continue
		answerString = answerString + '"%s",'%[a[0]]
	var substr = answerString.substr(0,len(answerString)-1)
	return  substr + ")"

func get_category_string(categories):
	var catString = ""
	for c in range(0,len(categories)):
		catString += categories[c].category +' = "'+categories[c].target +'" '
		if c != len(categories)-1:
			catString += "AND "
	return catString

func random_pokemon(categories = [], selections = ["*"], limit = 1):
	var queryStr = "Select "+ select_string(selections) +" From Pokemon"
	if len(categories) > 0:
		queryStr=queryStr+ " WHERE " + get_category_string(categories) + "ORDER BY RANDOM() LIMIT " + str(limit) + ";"
	else:
		"Select "+ select_string(selections) +" From Pokemon ORDER BY RANDOM() LIMIT " + str(limit) + ";"
	pokemonDB.query(queryStr)
	if len(pokemonDB.query_result) < 1:
		return null
	if limit == 1:
		return pokemonDB.query_result[0]
	else:
		return pokemonDB.query_result

#region Helper Functions
func weighted_choice(answers:Array):
	var sum = 0
	for s in answers:
		sum += s[1]
	var rand = random.randi_range(0,sum-1)
	for s in answers:
		if rand < s[1]:
			return s
		rand -= s[1]
	assert("Fucked up weighted choice.")


class Category:
	var category
	var target
	func _init(cat, targ):
		self.category = cat
		self.target = targ
	


#endregion
#region Query string constructors

func select_string(selections):
	#print(selections)
	var selString = ""
	var lastSel = selections[selections.size() - 1]
	for s in selections:
		selString = selString + s + " "
		if s != lastSel:
			selString = selString + ", "
	return selString

func category_string(categories):
	var catstring = ""
	var lastC = categories[categories.size()-1]
	for c in categories:
		catstring = catstring + c[0] + ' = "' + c[1] + '" '
		if c != lastC:
			catstring = catstring + "AND "
	return catstring

func image_name(pokeNat:String):
	var pokeDex = pokeNat.pad_zeros(4)
	var pDex = pokeDex.split(".")
	if len(pDex) > 1:
		pokeDex = pDex[0]+"_"+pDex[1].pad_zeros(2)
	return pokeDex

#endregion
#region Testing Functions
func test_weighted_choice(category, repetitions: int):
	var results = {}
	for i in range(repetitions):
		var choice = weighted_choice(currentCategoryAnswers[category])
		var name = choice[0]
		if name in results:
			results[name] += 1
		else:
			results[name] = 1
	#print(results)
#endregion
#region Old Functions
func validate_pokemon(pokemonName, categories:Array[Category]):
	var r = pokemonDB.select_rows("Pokemon", 'Name="%s"'%[pokemonName],["*"])
	#print(r)
	if len(r) > 1:
		assert("Data incorrect!")
	var pokeTypes = []
	for x in categories:
		if "Type" in x.category:
			pokeTypes.append(x.target)
	#print(pokeTypes)
	var typeBool = type_validation(r[0], pokeTypes)
	if len(pokeTypes) == 1:
		if typeBool == false:
			return false
	elif len(pokeTypes) > 1 and typeBool:
		return true

	for x in categories:
		if x.target != r[0][x.category]:
			return false
	return true


func random_category(firstPick = false, blacklistCategories = []):
	var categories = currentCategories.duplicate()
	if len(blacklistCategories) > 0:
		for b in blacklistCategories:
			categories.erase(b)
	if firstPick:
		while true:
			var validCat = categories[random.randi_range(0,len(categories)-1)]
			if validCat in validFirstCategories:
				return validCat
	else:
		return categories[random.randi_range(0,len(categories)-1)]

func random_category_answer(category, weighted = true, blacklistAnswers = []):
	var catAnswers = currentCategoryAnswers[category].duplicate()
	if len(blacklistAnswers) > 0:
		for b in blacklistAnswers:
			catAnswers.erase(b)
	if weighted:
		return weighted_choice(catAnswers)[0]
	else:
		return catAnswers[random.randi_range(0,len(catAnswers)-1)][0]

#This function is used for validating the types. Since there are Type1 and Type2 this is
#required in order to get the correct answer.
func type_validation(pokemon, types):
	##ALERT: Might need to come back and check this?
	for x in range(0,len(types)):
		if not(types[x] == pokemon["Type1"] or types[x] == pokemon["Type2"]):
			return false
	return true
#endregion



