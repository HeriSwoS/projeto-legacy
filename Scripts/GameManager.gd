# GameManager.gd (ou Main.gd)
extends Node2D

# Pré-carregue a cena da carta
const CardScene = preload("res://Scenes/Card.tscn")

# Exporte um array para arrastar seus recursos de carta no inspetor
@export var deck_data: Array[CardData]

var player_hand_node: Node2D
var hand: Array = []

func _ready():
	$PlayerHand.add_to_group("player_hand")

	# Adiciona este nó ao grupo "game_manager" para que CardManager possa encontrá-lo
	add_to_group("game_manager")
	
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
	
	# Debug: Verificar se está no grupo correto
	print("GameManager adicionado ao grupo 'game_manager': ", is_in_group("game_manager"))

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
		if child.is_in_group("is_card") and not child.top_level:
			cards.append(child)
	
	var spacing = 150.0
	for i in range(cards.size()):
		var target_x = (i - (cards.size() - 1) / 2.0) * spacing
		var tween = create_tween()
		tween.tween_property(cards[i], "position", Vector2(target_x, 0), 0.25).set_trans(Tween.TRANS_SINE)

# Reorganiza o array 'hand' baseado na posição da carta arrastada
func reorder_hand_by_position(dragged_card: Card):
	var hand_node = $PlayerHand
	var cards_in_hand = []
	
	# Coleta todas as cartas que estão na mão (não arrastadas)
	for child in hand_node.get_children():
		if child.is_in_group("is_card") and not child.top_level:
			cards_in_hand.append(child)
	
	# Se a carta arrastada não está mais na mão, não faz nada
	if not dragged_card in cards_in_hand:
		print("Carta não está na mão, ignorando reorganização")
		return
	
	# Debug: Mostrar cartas antes de reorganizar
	print("Reorganizando mão. Cartas antes: ", cards_in_hand.size())
	
	# Ordena as cartas por posição X
	cards_in_hand.sort_custom(func(a, b): return a.position.x < b.position.x)
	
	# Debug: Mostrar ordem após sort
	print("Cartas reordenadas por posição X")
	
	# Atualiza o array 'hand' com a nova ordem
	hand.clear()
	for card in cards_in_hand:
		if card in hand_node.get_children():
			hand.append(card)
	
	# Debug: Mostrar novo array
	print("Array 'hand' atualizado com ", hand.size(), " cartas")
	
	# IMPORTANTE: Chamar update_hand_positions AQUI para animar as cartas para as novas posições
	update_hand_positions()
