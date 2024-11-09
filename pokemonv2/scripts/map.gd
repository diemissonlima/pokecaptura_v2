extends Control
class_name MapManagement

var aux_list: Array = []

var current_money: int


func _ready() -> void:
	for button in get_tree().get_nodes_in_group("button_map"):
		button.pressed.connect(on_button_pressed.bind(button.name))
	
	current_money = SQL.verify_item_amount_on_inventory("Credito")


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("show_map"):
		visible = not visible


func on_button_pressed(button_name: String) -> void:
	if current_money < 500:
		return
	
	var new_map: String = "res://scenes/map_management/" + button_name.to_lower() + ".tscn"
	
	current_money -= 500
	
	SQL.update_database("inventario", "name", "decrease", current_money)
	SQL.db.update_rows("misc", "name = 'current_map'", {"value": button_name.to_lower()})
	
	transition_manager.fade_to_scene(new_map)
