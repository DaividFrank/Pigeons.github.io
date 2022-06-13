extends Control

onready var PoopScene = preload("res://Poop.tscn")
onready var BodyScene = preload("res://Body.tscn")
onready var GhostScene = preload("res://Ghost.tscn")

var tween : Tween
var scnd_tween : Tween
var body_tween : Tween
var pigeon_tween : Tween
var feeds := 0
var once := true
var twice := true
var stain := 0
var stop = false
var bodies := 0
var timer := 3.0
var can_move := true
var hor_dir = pow(-1, randi() % 2)
var ver_dir = pow(-1, randi() % 2)
var first_win := false
var feed_time := 0.0
var first_pigeon := true

const WIN_TIME = 30.0

const HOR_MIN = 90
const HOR_MAX = 590
const VER_MIN = 180
const VER_MAX = 1190
const BODY_VER_BASE = 1000
const BODY_VER_STEP = 200
const BODY_HOR_BASE = 150
const BODY_HOR_STEP = 430


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	tween = Tween.new()
	scnd_tween = Tween.new()
	body_tween = Tween.new()
	pigeon_tween = Tween.new()
	add_child(tween)
	add_child(scnd_tween)
	add_child(body_tween)
	add_child(pigeon_tween)
	$Hearts/First.visible = false
	$Hearts/Second.visible = false
	$Hearts/Third.visible = false
	$Hearts/Fourth.visible = false
	$Hearts/Fifth.visible = false
	$Music.play()
	$BG/AnimationPlayer.play("Play")

	var _ok = tween.interpolate_callback(self, 2, "start_scroll")
	_ok = tween.start()

func start_scroll():
	var _ok = tween.interpolate_property($BG, "global_position", Vector2(0, 0), Vector2(0,-1200), 4, Tween.TRANS_LINEAR, Tween.EASE_IN)
	_ok = tween.interpolate_callback(self, 6.3, "finish_scroll")
	_ok = tween.start()

func finish_scroll():
	var _ok = tween.interpolate_property($BG, "global_position", $BG.global_position, Vector2(0,-2900), 5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	_ok = tween.interpolate_callback(self, 6.5, "restart_pigeon")
	_ok = tween.interpolate_callback($Hearts/AnimationPlayer, 7, "play", "Show")
	_ok = tween.interpolate_callback(self, 6, "restart_bread")
	_ok = tween.start()


func restart_bread():
	$Feed.visible = true
	$Feed/AnimationPlayer.play("Mov")

func restart_pigeon():
	var spawn = $RightSpawn
	var mov_time = 0.5
	var extra_time = 2.8
	if !first_pigeon:
		extra_time = 1
		mov_time *= 4
		if randi() % 2:
			spawn = $LeftSpawn
	else:
		first_pigeon = false
	$Pigeon.visible = false
	$Pigeon.scale.x = -1 if spawn == $LeftSpawn else 1
	var _ok = pigeon_tween.interpolate_property($Pigeon, "global_position", spawn.global_position, $PigeonLoc.global_position, mov_time, Tween.TRANS_LINEAR, Tween.EASE_IN)
	_ok = pigeon_tween.interpolate_property($Pigeon, "visible", false, true, 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN)
	_ok = pigeon_tween.interpolate_property(self, "stop", true, false, mov_time, Tween.TRANS_LINEAR, Tween.EASE_IN)
	_ok = pigeon_tween.interpolate_property(self, "can_move", false, true, mov_time + extra_time, Tween.TRANS_LINEAR, Tween.EASE_IN)
	_ok = pigeon_tween.start()
	$Pigeon/AnimationPlayer.play("Idle1")
	$Pigeon/AnimationPlayer.seek(0)
	$Pigeon/SFX.play(0)
	$Pigeon.get_node("Timer").start()

func change_pigeon_dir():
	hor_dir = pow(-1, randi() % 2)
	ver_dir = pow(-1, randi() % 2)
	$Pigeon.scale.x = -1 if hor_dir > 0 else 1

func move_pigeon(delta):
	randomize()
	var new_position = $Pigeon.global_position + (delta * Vector2(hor_dir * int(rand_range(1,25)), ver_dir * int(rand_range(1,25))))
	while new_position.x < HOR_MIN or new_position.x > HOR_MAX or new_position.y < VER_MIN or new_position.y > VER_MAX:
		change_pigeon_dir()
		new_position = $Pigeon.global_position + (delta * Vector2(hor_dir * int(rand_range(1,25)), ver_dir * int(rand_range(1,25))))
	$Pigeon.global_position = new_position

func celebrate():
	$Confetti.visible = true
	$Pigeon.scale.x = 1
	$Pigeon/AnimationPlayer.play("celebrate")
	var _ok = tween.interpolate_property($Pigeon, "global_position", $Pigeon.global_position, $PigeonLoc.global_position + Vector2(0, -150), 2, Tween.TRANS_LINEAR, Tween.EASE_IN)
	_ok = tween.start()

func exit_pigeon():
	$Pigeon.scale.x = -1
	$Feed/AnimationPlayer.play("Exit")
	var _ok = tween.interpolate_property($Pigeon, "global_position", $Pigeon.global_position, $RightSpawn.global_position, 2, Tween.TRANS_LINEAR, Tween.EASE_IN)
	_ok = tween.interpolate_property($Hearts, "global_position", $Hearts.global_position, $Hearts.global_position + Vector2(0, 900), 2.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	_ok = tween.interpolate_callback(self, 2, "celebrate")
	_ok = tween.start()

func win():
	if first_win:
		return
	first_win = true
	$Pigeon/AnimationPlayer.play("Haste")
	$Pigeon/Timer.stop()
	$Pigeon/Timer2.stop()
	$Pigeon/SFX.stop()
	$Music.stop()
	$WinMusic.play(7)
	var _ok = tween.interpolate_callback(self, 2.5, "exit_pigeon")
	_ok = tween.interpolate_property($Pigeon, "global_position", $Pigeon.global_position, $PigeonLoc.global_position, 1, Tween.TRANS_LINEAR, Tween.EASE_IN)
	_ok = tween.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if feeds == 0 and feed_time >= WIN_TIME:
		win()
		stop = true
		return
	if feeds == 0:
		feed_time += delta
	if stop or !can_move or feeds == 4:
		return
	move_pigeon(delta)
	timer -= delta
	if timer <= 0:
		change_pigeon_dir()
		timer = 3.0

func start_ghost(ghost):
	ghost.get_node("AnimationPlayer").play("Idle")
	ghost.can_move = true


func dead():
	var body = BodyScene.instance()
	var ghost = GhostScene.instance()
	$Hearts/AnimationPlayer.play("Disappear")
	$Bodies.add_child(body)
	var mov = Vector2(-20, -300)
	mov.x *= $Pigeon.scale.x
	ghost.global_position = $Pigeon.global_position + mov
	body.global_position = $Pigeon.global_position
	body.scale = $Pigeon.scale
	ghost.visible = false
	ghost.get_node("AnimationPlayer").play("Spawn")
	body.get_node("AnimationPlayer").play("fade")
	ghost.z_index = 1
	$Bodies.add_child(ghost)
	var _ok = body_tween.interpolate_callback(body, 5, "queue_free")
	_ok = body_tween.interpolate_callback(self, 2, "start_ghost", ghost)
	#var body_pos = Vector2(BODY_HOR_BASE + (BODY_HOR_STEP * (bodies % 2)),
	#					   BODY_VER_BASE - (BODY_VER_STEP * (int(bodies / 2.0))))
	#var _ok = body_tween.interpolate_property(body, "global_position", $Pigeon.global_position, body_pos, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	_ok = body_tween.start()
	can_move = false
	_ok = scnd_tween.interpolate_callback(self, 2.5, "restart_pigeon")
	_ok = scnd_tween.interpolate_callback($Hearts/AnimationPlayer, 3, "play", "Show")
	_ok = scnd_tween.start()
	#bodies += 1
	stop = false

func poop():
	var poop = PoopScene.instance()
	poop.get_node("AnimationPlayer").play("{num}".format({"num":  (randi() % 3) + 1}))
	$Poops.add_child(poop)
	var pigeon_pos = $Pigeon.global_position
	if $Pigeon.scale.x == -1:
		pigeon_pos -= Vector2(50, 0)
	poop.global_position = pigeon_pos
	match feeds:
		1:
			$Hearts/AnimationPlayer.play("Del5")
		2:
			$Hearts/AnimationPlayer.play("Del4")
		3:
			$Hearts/AnimationPlayer.play("Del3")
		4:
			$Hearts/AnimationPlayer.play("Del2")
	# scnd_tween.interpolate_property($Poop, "visible", true, false, 1, Tween.TRANS_CUBIC, Tween.EASE_IN)
	# scnd_tween.interpolate_property($Poop, "global_position", $StartPoop.global_position, $EndPoop.global_position, 1, Tween.TRANS_LINEAR, Tween.EASE_IN)
	# scnd_tween.start()
	stop_feed()

func pigeon_poop():
	if feeds < 4:
		$Pigeon/AnimationPlayer.play("Pooping{num}".format({"num": feeds + 1}))

	var _ok = tween.interpolate_callback(self, 1.5, "poop")
	_ok = tween.interpolate_callback($Pigeon/Poop, 0.5, "play")
	_ok = tween.start()
	# if get_node_or_null("Stain%d" % stain) != null:
	# 	tween.interpolate_property(get_node("Stain%d" % stain), "visible", false, true, 1, Tween.TRANS_CUBIC, Tween.EASE_IN)
	# 	stain += 1

func feed():
	feeds += 1
	if feeds / 5 == 1:
		$Pigeon/AnimationPlayer.play("Die")
		stop = true
		tween.interpolate_callback(self, 3, "dead")
		tween.start()
		feeds = 0
		return
	tween.interpolate_callback(self, 1.5, "pigeon_poop")
	$Pigeon/AnimationPlayer.play("Eat{num}".format({"num": feeds}))
	# if feeds % 3 == 0:
	# if feeds % 3 == 1:
	# 	$Pigeon/AnimationPlayer.play("Eat1")
	# if feeds % 3 == 2:
	# 	$Pigeon/AnimationPlayer.play("Eat2")
	tween.start()

func stop_feed():
	if feeds / 3 == 4:
		feeds = 50
		$Pigeon/AnimationPlayer.play("Die")
		# BRING PIGEON 4 5
		scnd_tween.interpolate_property($Pigeon4, "global_position", $Pigeon4.global_position, $Pigeon4.global_position + Vector2(-280, 0), 1, Tween.TRANS_LINEAR, Tween.EASE_IN)
		scnd_tween.interpolate_property($Pigeon5, "global_position", $Pigeon5.global_position, $Pigeon5.global_position + Vector2(265, 0), 1, Tween.TRANS_LINEAR, Tween.EASE_IN)
		scnd_tween.start()
		stop = true
	else:
		$Pigeon/AnimationPlayer.play("Idle{num}".format({"num": feeds + 1}))
		stop = false

func _on_Feed_pressed():
	feed_time = 0.0
	if stop:
		return
	$BreadSFX.play()
	var food_pos = -88 if $Pigeon.scale.x == 1 else 200
	tween.interpolate_property($Feed, "disabled", true, false, 1.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.interpolate_property($Food, "global_position", $StartFood.global_position, $Pigeon.global_position + Vector2(food_pos, 0), 1.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.interpolate_property($Food, "visible", true, false, 1.5, Tween.TRANS_CUBIC, Tween.EASE_IN)
	tween.interpolate_callback(self, 0.75, "feed")
	stop = true
	tween.start()


func old_feed():
	feeds += 1
	tween.interpolate_property($Poop, "visible", true, false, 1, Tween.TRANS_CUBIC, Tween.EASE_IN)
	if get_node_or_null("Stain%d" % stain) != null:
		tween.interpolate_property(get_node("Stain%d" % stain), "visible", false, true, 1, Tween.TRANS_CUBIC, Tween.EASE_IN)
		stain += 1
	scnd_tween.interpolate_property($Poop, "global_position", $StartPoop.global_position, $EndPoop.global_position, 1, Tween.TRANS_LINEAR, Tween.EASE_IN)
	if feeds / 3 == 0:
		$Pigeon/AnimationPlayer.play("Eat")
	if feeds / 3 == 1:
		# BRING PIGEON 2
		if once:
			scnd_tween.interpolate_property($Pigeon2, "global_position", $Pigeon2.global_position, $Pigeon2.global_position + Vector2(265, 0), 1, Tween.TRANS_LINEAR, Tween.EASE_IN)
			once = false
		$Pigeon/AnimationPlayer.play("Eat1")
	if feeds / 3 == 2:
		# BRING PIGEON 3
		if twice:
			scnd_tween.interpolate_property($Pigeon3, "global_position", $Pigeon3.global_position, $Pigeon3.global_position + Vector2(-280, 0), 1, Tween.TRANS_LINEAR, Tween.EASE_IN)
			twice = false
		$Pigeon/AnimationPlayer.play("Eat2")
	if feeds / 3 == 3:
		$Pigeon/AnimationPlayer.play("Eat3")
	scnd_tween.start()
