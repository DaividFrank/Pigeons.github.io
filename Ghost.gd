extends Sprite


var hor_dir = pow(-1, randi() % 2)
var ver_dir = pow(-1, randi() % 2)

const HOR_MIN = 90
const HOR_MAX = 590
const VER_MIN = 180
const VER_MAX = 1190
var timer := 2.0
var can_move := false
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func change_dir():
	hor_dir = pow(-1, randi() % 2)
	ver_dir = pow(-1, randi() % 2)

func move_ghost(delta):
	randomize()
	var new_position = global_position + (delta * 2 * Vector2(hor_dir * int(rand_range(1,25)), ver_dir * int(rand_range(1,25))))
	while new_position.x < HOR_MIN or new_position.x > HOR_MAX or new_position.y < VER_MIN or new_position.y > VER_MAX:
		change_dir()
		new_position = global_position + (delta * Vector2(hor_dir * int(rand_range(1,25)), ver_dir * int(rand_range(1,25))))
	global_position = new_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !can_move:
		return
	move_ghost(delta)
	timer -= delta
	if timer <= 0:
		change_dir()
		timer = 2.0
