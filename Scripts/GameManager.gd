# GameManager.gd (ou Main.gd)
extends Node2D

# Pré-carregue a cena da carta
const CardScene = preload("res://Scenes/Card.tscn")

# Exporte um array para arrastar seus recursos de carta no inspetor
@export var deck_data: Array[CardData]

var player_hand_node: Node2D
var hand: Array = []

func _ready():
	# Pega o tamanho da janela do jogo
	var screen_size = get_viewport_rect().size

	# Encontra o nó da mão do jogador
	player_hand_node = $PlayerHand

	# Posiciona o nó da mão no centro da parte inferior da tela
	player_hand_node.position.x = screen_size.x / 2
	player_hand_node.position.y = screen_size.y - 100 # Ex: 100 pixels acima da borda inferior
	# Embaralha o baralho no início do jogo
	deck_data.shuffle()
	# Compra 5 cartas iniciais
	for i in range(5):
		draw_card()

func draw_card():
	if deck_data.is_empty():
		print("Baralho vazio!")
		update_deck_visual()
		return

	var data = deck_data.pop_front()
	var new_card = CardScene.instantiate() as Card

	# Verifique se a instância é válida antes de chamar a função
	if new_card:
		new_card.setup(data)
		hand.append(new_card)
		player_hand_node.add_child(new_card)
		update_hand_positions()
		update_deck_visual()
	else:
		# Se new_card for nulo, significa que o nó raiz de CardScene.tscn não é um "Card"
		push_error("Erro ao instanciar carta.")
		
func update_deck_visual():
	var deck_node = get_tree().get_first_node_in_group("deck")
	if deck_node and deck_node.has_method("update_count"):
		deck_node.update_count(deck_data.size())
		
func update_hand_positions():
	var hand_node = $PlayerHand
	var cards = []
	for child in hand_node.get_children():
		# Só organiza cartas que NÃO estão sendo arrastadas (top_level = false)
		if child.is_in_group("is_card") and not child.top_level:
			cards.append(child)
	
	var spacing = 150.0
	for i in range(cards.size()):
		var target_x = (i - (cards.size() - 1) / 2.0) * spacing
		create_tween().tween_property(cards[i], "position", Vector2(target_x, 0), 0.25).set_trans(Tween.TRANS_SINE)
