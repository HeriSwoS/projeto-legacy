extends Control
class_name GraveyardZone

@onready var count_label = $CountLabel
@onready var cards_container = $GyCardsContainer

var graveyard_cards: Array = []

func _ready():
	add_to_group("graveyard")
	update_count()

# Adiciona uma carta ao cemitério
func add_card(card: Card):
	# Se a carta já está no cemitério, remove primeiro
	if card in graveyard_cards:
		print("DEBUG: Carta já estava no cemitério, removendo do array")
		graveyard_cards.erase(card)
	
	# Agora adiciona a carta
	graveyard_cards.append(card)
	card.top_level = false
	card.reparent(cards_container)
	card.position = Vector2.ZERO
	update_count()
	print("Carta adicionada ao cemitério: ", card.card_data.card_name)

# Remove uma carta do cemitério
func remove_card(card: Card):
	if card in graveyard_cards:
		graveyard_cards.erase(card)
		update_count()
		print("Carta removida do cemitério: ", card.card_data.card_name)

# Atualiza o contador visual
func update_count():
	count_label.text = str(graveyard_cards.size())

# Retorna todas as cartas no cemitério
func get_all_cards() -> Array:
	return graveyard_cards.duplicate()

# Limpa o cemitério
func clear_graveyard():
	graveyard_cards.clear()
	update_count()
	print("Cemitério limpo")
