# Card.gd
class_name Card # <--- ADICIONE ESTA LINHA
extends Area2D

var card_data: CardData


# Esta função preenche a carta visual com os dados do Resource
func setup(data: CardData):
	card_data = data
	$Artwork.texture = card_data.artwork
	$NameLabel.text = card_data.card_name
	$CostLabel.text = str(card_data.cost)
	$DescriptionLabel.text = card_data.description
	
func _ready():
	add_to_group("cards")
