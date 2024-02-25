extends Button


@export var pokeSearch : LineEdit
@onready var texture = $texture


func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_pressed():
	pokeSearch.show()
	pokeSearch.setButton(self)
	pokeSearch.grab_focus()


func set_texture(tex):
	print(tex)
	texture.texture = tex
