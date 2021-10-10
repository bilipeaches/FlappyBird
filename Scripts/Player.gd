extends KinematicBody2D

# 鸟的颜色
var birds_color = {
	"0":"Yellow",
	"1":"Blue",
	"2":"Red"
}
# 鸟的旋转速度
var r_speed = 4
var r = 0
# 鸟的速度
var up_speed = 200
var down_speed = 15
# 游戏开始
var game_start = false
# 游戏结束
var game_over = false
var player = Vector2()

func _ready():
	# 随机鸟的颜色
	randomize() #随机种子
	$Bird.play(birds_color[str(randi() % 3)])

func GameSart():
	game_start = true

# 触屏
var touch = false
func _input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			touch = true
		else:
			touch = false

# warning-ignore:unused_argument
func _physics_process(delta):
	raise()
	if game_start:
		# 重力
		player.x = 0
		player.y += down_speed
		# 鼠标单击时，给它一个向上的力
		if touch or Input.is_action_just_pressed("ui_accept"):
			# 清空叠加重力
			player.y = 0
			player.y -= up_speed
			$AudioStreamPlayer2D.play()
		# 调整方向
		if player.y < 0 and r >= -20:
			r = -20
		else:
			r = 20
		if rotation_degrees > r:
			rotation_degrees -= r_speed
		else:
			rotation_degrees += r_speed
		# warning-ignore:return_value_discarded
		player = move_and_slide(player)
		# 检测Player是否飞过屏幕上方
		if position.y < 0:
			get_node("../").game_over = true
			get_node("../").GameOver()
			GameOver()
	elif game_over and position.y <= 384:
		position.y += 10

# 游戏结束
func GameOver():
	game_start = false
	game_over = true
	$Bird.stop()
	$AnimationPlayer.play("GameOver")
