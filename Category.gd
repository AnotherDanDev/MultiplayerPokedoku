extends Label


# Called when the node enters the scene tree for the first time.
func _ready():
	change_category("Water")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func change_category(cat):
	text = cat
	$AnimationPlayer.play("Fade In")
