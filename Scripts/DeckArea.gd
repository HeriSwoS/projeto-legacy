extends Control
class_name DeckArea

@onready var count_label = $CountLabel

func _ready():
	add_to_group("deck")

# Esta função será criada automaticamente quando você conectar o sinal 'pressed'
func _on_button_pressed():
	comprar_carta()

func comprar_carta():
	# 1. Pega o nó Raiz (onde está o seu GameManager.gd)
	var gm = get_tree().current_scene
	
	# 2. Chama a função correta: draw_card()
	if gm and gm.has_method("draw_card"):
		gm.draw_card()
		print("Sucesso: Carta comprada usando draw_card!")
	else:
		print("Erro: Não encontrei a função draw_card no nó Raiz.")

func update_count(number: int):
	if count_label:
		count_label.text = str(number)
