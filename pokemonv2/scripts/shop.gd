extends Control
class_name PokeShop

@export_category("Objetos")
@export var money_icon: TextureRect
@export var name_item_label: Label
@export var cost_label: Label
@export var buy_button: Button
@export var alert: Label

var _purchase_value: int
var _item_name: String
var _amount: int


func _ready() -> void:
	for button in get_tree().get_nodes_in_group("button_shop"):
		button.pressed.connect(on_button_pressed.bind(button))


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("open_shop"):
		visible = not visible


func on_button_pressed(button: TextureButton) -> void:
	var amount: int
	var item_value: int
	
	match button.name:
		"Pokeball":
			item_value = 150
			
		"Greatball":
			item_value = 250
			
		"Ultraball":
			item_value = 400
	
	name_item_label.show()
	name_item_label.text = button.name + " x" + button.get_node("Label").text
	amount = int(button.get_node("Label").text)
	
	checkout(button.name, item_value, amount)
	

func checkout(button_name: String, item_value: int, amount: int) -> void:
	var new_value: int
	var purchase_value: int
	
	match amount:
		1:
			new_value = item_value
			
		5:
			new_value = item_value - 25
			
		10:
			new_value = item_value - 50
	
	purchase_value = new_value * amount
	
	cost_label.show()
	cost_label.text = "Custo: " + str(purchase_value) + " Créditos"
	
	money_icon.show()
	buy_button.show()
	
	_purchase_value = purchase_value
	_item_name = button_name
	_amount = amount


func _on_buy_button_pressed() -> void:
	if _purchase_value > SQL.verify_item_amount_on_inventory("Credito"):
		alert.show()
		alert.text = "Créditos Insuficiente!!!"
		await get_tree().create_timer(2.0).timeout
		alert.hide()
		return
	
	alert.show()
	alert.text = "Compra Realizada!!!"
	await get_tree().create_timer(2.0).timeout
	alert.hide()
	
	SQL.update_database("inventario", "Credito", "decrease", _purchase_value) # atualiza os Creditos do jogador
	SQL.update_database("inventario", _item_name, "increase", _amount) # atualiza o item comprado
	
	get_tree().call_group("screen_capture", "update_label_pokeball")
