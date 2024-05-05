extends Label

var count = 1
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func increase_Count():
	count += 1
	text = "Waiting for players (" + str(count) + "/4)"
