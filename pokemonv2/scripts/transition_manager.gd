extends CanvasLayer

var new_scene = ""

func fade_to_scene(_new_scene: String) -> void:
	visible = true
	new_scene = _new_scene
	$Animation.play("fade")
	

func change_scene() -> void:
	var _change_scene: bool = get_tree().change_scene_to_file(new_scene)
	
	await get_tree().create_timer(1.0).timeout
	visible = false
