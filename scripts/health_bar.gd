extends CanvasLayer

var hearts_list : Array[TextureRect]

func _ready() -> void:
	var hearts_parent = $HBoxContainer
	for child in hearts_parent.get_children():
		hearts_list.append(child)
	print(hearts_list)
	
	PlayerStats.health_changed.connect(_on_health_changed)
	PlayerStats.player_died.connect(_on_player_died)
	
	update_hearts(PlayerStats.current_health)

func _on_health_changed(new_health: int):
	update_hearts(new_health)

func update_hearts(health: int):
	for i in range(hearts_list.size()):
		if i >= (hearts_list.size() - health):
			hearts_list[i].modulate = Color.WHITE
		else:
			hearts_list[i].modulate = Color(0.3, 0.3, 0.3, 0.5)

func _on_player_died():
	print("All hearts lost!")
