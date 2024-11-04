extends ColorRect


func _on_new_game_pressed() -> void:
	var current_map: String
	SQL.db.query("SELECT value FROM misc WHERE name = 'current_map'")
	
	current_map = SQL.db.query_result[0]["value"]
	
	transition_manager.fade_to_scene("res://scenes/map_management/" + current_map + ".tscn")
