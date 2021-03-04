extends Sprite

onready var player = get_node("/root/World/Player")
var dist = 1000

func _process(_delta):
	print(player)
	dist = position.distance_to(player.position)
	if Input.is_action_just_pressed("attack") and dist < 50:
		queue_free()
