extends Control
class_name MapManagement


func _ready() -> void:
	for button in get_tree().get_nodes_in_group("button_map"):
		button.pressed.connect(on_button_pressed.bind(button.name))


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("show_map"):
		visible = not visible


func on_button_pressed(button_name: String) -> void:
	match button_name:
		"ButtonMap1":
			get_tree().change_scene_to_file("res://scenes/map_management/mapa_01.tscn")
		
		"ButtonMap2":
			get_tree().change_scene_to_file("res://scenes/map_management/mapa_02.tscn")
