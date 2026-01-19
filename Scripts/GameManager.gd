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
	var hand_node = $PlayerHand
	var cards = []
	
	# Pega apenas os filhos que são cartas
	for child in hand_node.get_children():
		if child.is_in_group("is_card"):
			cards.append(child)
	
	var hand_size = cards.size()
	var spacing = 150.0 # Espaço entre as cartas
	
	for i in range(hand_size):
		var card = cards[i]
		# Calcula a posição X centralizada
		var target_x = (i - (hand_size - 1) / 2.0) * spacing
		var target_pos = Vector2(target_x, 0)
		
		# Usa um Tween para mover as cartas suavemente para seus novos lugares
		var tween = create_tween()
		tween.tween_property(card, "position", target_pos, 0.25).set_trans(Tween.TRANS_SINE)
