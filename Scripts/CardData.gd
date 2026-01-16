class_name CardData
extends Resource

@export var card_name: String = "Nome da Carta"
@export var description: String = "Descrição do efeito."
@export var cost: int = 1
@export var artwork: Texture2D # A arte da carta. [6]

# Adicione outras propriedades que precisar:
@export var attack: int = 0
@export var health: int = 0
# ... etc
