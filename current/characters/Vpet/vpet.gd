extends Node2D


var moving: bool = false
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _physics_process(_delta: float) -> void:
	if not moving and rng.randi_range(0, 299) == 0:
		moving = true
		await create_tween().tween_property(self, "global_position:x", rng.randi_range(0, 1080), 5.0).finished
		moving = false
	global_position= global_position.clamp(Vector2(0, 0), Vector2(1080, 1600))
