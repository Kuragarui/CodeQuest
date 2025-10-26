extends Node2D

signal talked_to

func _ready():
	# Connect the signal when player enters the Area2D
	$Area2D.connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body.is_in_group("Player"):
		emit_signal("talked_to")
		print("Master Signal Received")
