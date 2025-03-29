extends CharacterBody2D

var pos:Vector2
var rota:float
var dir: float
var speed= 500
var lifetime = 2.0

func _ready():
	global_position=pos
	global_rotation=rota
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = lifetime
	timer.one_shot = true
	timer.timeout.connect(Callable(self, "queue_free"))
	timer.start()
	
func _physics_process(delta):
	velocity=Vector2(speed, 0).rotated(dir)
	move_and_slide()


func _on_area_2d_body_entered(body):
	
		queue_free()
