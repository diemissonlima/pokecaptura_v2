extends TextureRect

@export_category("Objetos")
@export var bank_container: GridContainer

var can_click: bool = false


func _ready() -> void:
	for slot in get_tree().get_nodes_in_group("slot_bank"): # for pra conectar o sinal de mouse entered/exited no slot
		slot.mouse_entered.connect(on_mouse_entered.bind(slot.id)) # sinal conectado com base no ID do slot
		#slot.mouse_exited.connect(on_mouse_exited.bind(slot.slot_id))
	
	add_pokemon_to_bank()
	

func add_pokemon_to_bank() -> void:
	pass


func on_mouse_entered(id: int) -> void:
	pass
