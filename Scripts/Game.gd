extends Node2D

# 白天和晚上
var day = preload("res://Assets/Images/bg_day.png")
var night = preload("res://Assets/Images/bg_night.png")
# 暂停和开始
var pause_img = preload("res://Assets/Images/button_pause.png")
var resume_img = preload("res://Assets/Images/button_resume.png")
var pause = false
# 游戏状态
var game_state = "run"
# 管子
var pipe_down
var pipe_up
var pd = preload("res://Scenes/Pipe_down.tscn")
var pu = preload("res://Scenes/Pipe_up.tscn")
# 分数
var score = 0
# 游戏结束
var game_over = false
# 玩家
var Player

func _ready():
	score = 0
	# 玩家
	Player = preload("res://Scenes/Player.tscn").instance()
	Player.position = Vector2(144, 256)
	add_child(Player)
	# 随机管子颜色
	randomize()
	if randi() % 2:
		pipe_down = preload("res://Assets/Images/pipe_down.png")
		pipe_up = preload("res://Assets/Images/pipe_up.png")
	else:
		pipe_down = preload("res://Assets/Images/pipe2_down.png")
		pipe_up = preload("res://Assets/Images/pipe2_up.png")
	# 获取现在的时间
	var time = OS.get_time()["hour"]
	# 看是晚上还是白天
	if int(time) > 18:
		$Background.texture = night
	else:
		$Background.texture = day

# 开始点击，游戏准备
func _on_Start_pressed():
	MusicPlayer.play_music("res://Assets/Audios/swoosh.wav")
	$AnimationPlayer.play("GameReady")
	yield($AnimationPlayer, "animation_finished")
	game_state = "ready"

# 触屏
var touch = false
func _input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			touch = true
		else:
			touch = false

# 循环
func _physics_process(delta):
	delta = delta # 没啥用只是为了消除警告
	# 如果在准备状态下鼠标左键，则游戏开始
	if touch and game_state == "ready":
		game_state = "start"
		$AnimationPlayer.play("GameStart")
		$MainUI/Land/AnimationPlayer.play("LandScroll")
		# 告诉Player游戏开始
		Player.GameSart()
		# 显示暂停按钮
		$MainUI/Pause.show()
		# 计时器开启
		$Pipe_Add_Timer.start()
	if !game_over:
		# 置顶
		$MainUI.raise()
		# 分数显示
		$MainUI/Score.text = str(score)

# 游戏暂停
func _on_Pause_pressed():
	if pause:
		pause = false
		get_tree().paused = false
		$MainUI/Pause.icon = pause_img
	else:
		pause = true
		get_tree().paused = true
		$MainUI/Pause.icon = resume_img

# 添加管子
func _on_Pipe_Add_Timer_timeout():
	randomize()
	# 管子-上
	var position_y = rand_range(-136, 140)
	var ppd = pd.instance()
	ppd.get_node("Sprite").texture = pipe_down
	ppd.position.x = 312
	ppd.position.y = position_y
	add_child(ppd)
	# 管子-下
	var ppu = pu.instance()
	ppu.get_node("Sprite").texture = pipe_up
	ppu.position.x = 312
	ppu.position.y = position_y + 320 + 100 # 320为管子长度,100为间隔
	add_child(ppu)

# 游戏结束
func GameOver():
	MusicPlayer.play_music("res://Assets/Audios/die.wav")
	game_state = "over"
	$Pipe_Add_Timer.stop()
	$MainUI/Land/AnimationPlayer.stop()
	$GameOverUI.raise()
	$AnimationPlayer.play("GameOver")
	$MainUI/Score.hide()
	# 显示分数
	$GameOverUI/score_panel/Score.text = str(score)
	# 最高分数检测与显示
	if EasySave.has_file("data.flappybird"):
		var best_score = EasySave.load_data_encryptioned_automatic("data.flappybird")
		if score > int(best_score):
			EasySave.save_data_encryptioned_automatic("data.flappybird", str(score))
			$GameOverUI/score_panel/Best.text = str(score)
		else:
			$GameOverUI/score_panel/Best.text = best_score
	else:
		EasySave.save_data_encryptioned_automatic("data.flappybird", str(score))
	# 奖牌
	var img = null
	if score >= 40:
		img = load("res://Assets/Images/medals_1.png")
	elif score >= 30:
		img = load("res://Assets/Images/medals_2.png")
	elif score >= 20:
		img = load("res://Assets/Images/medals_3.png")
	elif score >= 10:
		img = load("res://Assets/Images/medals_0.png")
	$GameOverUI/score_panel/medals.texture = img

# 撞到底部land
# warning-ignore:unused_argument
func _on_Land2_body_entered(body):
	if !game_over:
		MusicPlayer.play_music("res://Assets/Audios/hit.wav")
		game_over = true
		Player.GameOver()
		GameOver()

# 游戏菜单
func _on_Menu_pressed():
	game_state = "run"
	game_over = false
	$AnimationPlayer.play_backwards("GameOver")
	yield($AnimationPlayer, "animation_finished")
	$AnimationPlayer.play("Main")
	Player.queue_free()
	$MainUI/Pause.hide()
	$MainUI/Score.show()
	$MainUI.raise()
	_ready()

# 截屏
func _on_Share_pressed():
	$GameOverUI/FileDialog.popup_centered()

# 保存
func _on_FileDialog_dir_selected(dir):
	$GameOverUI/FileDialog.hide()
	yield(get_tree().create_timer(0.5), "timeout")
	var image = get_viewport().get_texture().get_data()
	image.flip_y()
	image.save_png(dir + "/screenshot.png")
	$TS/AnimationPlayer.play("TS")
	yield(get_tree().create_timer(2), "timeout")
	$TS/AnimationPlayer.play_backwards("TS")
