extends Node2D

func open_door():
	if has_node("CollisionShape2D"):
		$CollisionShape2D.disabled = true
	elif has_node("StaticBody2D/CollisionShape2D"):
		$StaticBody2D/CollisionShape2D.disabled = true

	print("Door unlocked: Player can walk through now.")
