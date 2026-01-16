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
		return

	var data = deck_data.pop_front()

	# Adicione "as Card" para garantir o tipo correto
	var new_card = CardScene.instantiate() as Card

	# Verifique se a instância é válida antes de chamar a função
	if new_card:
		new_card.setup(data)
		hand.append(new_card)
		player_hand_node.add_child(new_card)
		update_hand_positions()
	else:
		# Se new_card for nulo, significa que o nó raiz de CardScene.tscn não é um "Card"
		push_error("A cena instanciada não é do tipo 'Card'. Verifique o script anexado ao nó raiz de Card.tscn.")

func update_hand_positions():
	# Lógica para organizar as cartas na mão (ex: em um arco)
	var hand_size = hand.size()
	for i in range(hand_size):
		var card = hand[i]
		var target_x = (i - (hand_size - 1) / 2.0) * 150 # Espaçamento horizontal
		card.position = Vector2(target_x, 0)
