extends Control
class_name MapManagement

var aux_list: Array = []


func _ready() -> void:
	for button in get_tree().get_nodes_in_group("button_map"):
		button.pressed.connect(on_button_pressed.bind(button.name))


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("show_map"):
		visible = not visible


func on_button_pressed(button_name: String) -> void:
	var new_map: String = "res://scenes/map_management/" + button_name.to_lower() + ".tscn"
	
	transition_manager.fade_to_scene(new_map)
