extends Area2D

# 速度
var speed = 140
# 是否加过分
var is_score = false

func _physics_process(delta):
	if !get_node("../").game_over:
		position.x -= speed * delta
		if position.x <= OS.get_real_window_size().x / 2 and !is_score:
			is_score = true
			get_node("../").score += 0.5
			MusicPlayer.play_music("res://Assets/Audios/point.wav")
	else:
		queue_free()

# 当移除场景则销毁
func _on_VisibilityNotifier2D_screen_exited():
	queue_free()

# 游戏结束
func _on_Pipe_body_entered(body):
	MusicPlayer.play_music("res://Assets/Audios/hit.wav")
	get_node("../").game_over = true
	get_node("../").GameOver()
	body.GameOver()
