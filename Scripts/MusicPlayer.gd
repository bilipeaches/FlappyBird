extends Node

func play_music(path):
	var player = AudioStreamPlayer2D.new()
	player.stream = load(path)
	get_node(".").add_child(player)
	player.play()
	yield(player, "finished")
	player.queue_free()
