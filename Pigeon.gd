extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	# $Sprite.visible = true
	$AnimationPlayer.play("Eat1")
	$AnimationPlayer.seek(0, true)
	# $AnimationPlayer.play("Idle1")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_Timer_timeout():
	$SFX.play(0)
	$Timer2.start()


func _on_Timer2_timeout():
	$SFX.stop()
	$Timer.start()
