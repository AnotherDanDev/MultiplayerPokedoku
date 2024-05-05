extends Button


@onready var texture = $texture
var controller:CellControl
var solved = false


func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_pressed():
	controller.cell_pressed(self.name)

func set_texture(tex):
	texture.texture = tex

