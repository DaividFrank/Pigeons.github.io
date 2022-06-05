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

	tween.interpolate_callback(self, 2, "start_scroll")
	tween.start()

func start_scroll():
	tween.interpolate_property($BG, "global_position", Vector2(0, 0), Vector2(0,-1000), 3, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.interpolate_callback(self, 5, "finish_scroll")
	tween.start()
	
func finish_scroll():
	tween.interpolate_property($BG, "global_position", $BG.global_position, Vector2(0,-2900), 10, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.interpolate_property($Feed, "visible", false, true, 20, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.interpolate_property($Pigeon, "visible", false, true, 20.3, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.interpolate_callback(self, 10, "restart_pigeon")
	tween.start()

func restart_pigeon():
	var spawn = $LeftSpawn
	if randi() % 2:
		spawn = $RightSpawn
	var _ok = pigeon_tween.interpolate_property($Pigeon, "global_position", spawn.global_position, $PigeonLoc.global_position, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	_ok = pigeon_tween.interpolate_property(self, "stop", true, false, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	_ok = pigeon_tween.interpolate_property(self, "can_move", false, true, 1, Tween.TRANS_LINEAR, Tween.EASE_IN)
	pigeon_tween.start()
	$Pigeon/AnimationPlayer.play("Idle1")
	$Pigeon/AnimationPlayer.seek(0)
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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if stop or !can_move or feeds == 4:
		return
	move_pigeon(delta)
	timer -= delta
	if timer <= 0:
		change_pigeon_dir()
		timer = 3.0

func dead():
	var body = BodyScene.instance()
	var ghost = GhostScene.instance()
	$Bodies.add_child(body)
	$Bodies.add_child(ghost)
	ghost.global_position = $Pigeon.global_position
	body.global_position = $Pigeon.global_position
	body.scale = $Pigeon.scale
	body.get_node("AnimationPlayer").play("fade")
	var _ok = body_tween.interpolate_callback(body, 5, "queue_free")
	#var body_pos = Vector2(BODY_HOR_BASE + (BODY_HOR_STEP * (bodies % 2)),
	#					   BODY_VER_BASE - (BODY_VER_STEP * (int(bodies / 2.0))))
	#var _ok = body_tween.interpolate_property(body, "global_position", $Pigeon.global_position, body_pos, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	body_tween.start()
	restart_pigeon()
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
	# scnd_tween.interpolate_property($Poop, "visible", true, false, 1, Tween.TRANS_CUBIC, Tween.EASE_IN)
	# scnd_tween.interpolate_property($Poop, "global_position", $StartPoop.global_position, $EndPoop.global_position, 1, Tween.TRANS_LINEAR, Tween.EASE_IN)
	# scnd_tween.start()
	stop_feed()

func pigeon_poop():
	if feeds < 4:
		$Pigeon/AnimationPlayer.play("Pooping{num}".format({"num": feeds + 1}))
	tween.interpolate_callback(self, 1.5, "poop")
	tween.start()
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
