extends Label


func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func change_category(cat):
	text = cat
	$AnimationPlayer.play("Fade In")
