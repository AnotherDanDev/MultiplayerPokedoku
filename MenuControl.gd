extends Control

var animation:AnimationPlayer
var players

var fakeplayer = preload("res://FakePlayer.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	animation = $AnimationPlayer
	players = $Panel/Multiplayer/Players

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_multiplayer_pressed():
	animation.play("MainMenuFadeOut")

	
func add_player():
	players.add_child(fakeplayer.instantiate())



func _on_animation_player_animation_finished(anim_name):
	if anim_name == "MainMenuFadeOut":
		animation.play("AddingPlayers")
