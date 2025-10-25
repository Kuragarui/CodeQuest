extends Node2D

const SPEED = 60
var direction = 1
var is_interacting = false

@onready var ray_cast_right = $RayCastRight
@onready var ray_cast_left = $RayCastLeft
@onready var animated_sprite = $AnimatedSprite2D

func _process(delta):
	if not is_interacting:
		if ray_cast_right.is_colliding():
			direction = -1
			animated_sprite.flip_h = true
		elif ray_cast_left.is_colliding():
			direction = 1
			animated_sprite.flip_h = false
		
		position.x += direction * SPEED * delta


func _on_Area2D_body_entered(body):
	if body.is_in_group("Player"):
		is_interacting = true
		show_dialog()


func _on_Area2D_body_exited(body):
	if body.is_in_group("Player"):
		is_interacting = false
		print(" The monster watches you leave...")

func show_dialog():
	print(" Monster: You dare approach the chest? Answer my coding riddle!")
