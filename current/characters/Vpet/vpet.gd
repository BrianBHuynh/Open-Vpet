extends Node2D


var current_animation: String = "idle"
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _physics_process(_delta: float) -> void:
	if current_animation == "idle":
		if rng.randi_range(0, 299) == 0:
			if rng.randi_range(0, 1) == 0:
				current_animation = "jump"
			else:
				current_animation = "walk"
			$AnimatedSprite2D.play(current_animation)
			var next_x_pos: int = rng.randi_range(0, 1080)
			if next_x_pos > global_position.x:
				scale.x = 1.0
			else:
				scale.x = -1.0
			await create_tween().tween_property(self, "global_position:x", rng.randi_range(0, 1080), 5.0).finished
			current_animation = "idle"
			$AnimatedSprite2D.play(current_animation)
		elif rng.randi_range(0, 299) == 0:
			match randi_range(0, 6):
				0:
					current_animation = "angry"
				1:
					current_animation = "grumpy"
				2:
					current_animation = "happy"
				3:
					current_animation = "jump"
				4:
					current_animation = "laugh"
				5:
					current_animation = "love"
				6:
					current_animation = "sick"
		$AnimatedSprite2D.play(current_animation)
	
	global_position= global_position.clamp(Vector2(0, 0), Vector2(1080, 1600))


func _on_animated_sprite_2d_animation_finished() -> void:
	current_animation = "idle"
	$AnimatedSprite2D.play(current_animation)
