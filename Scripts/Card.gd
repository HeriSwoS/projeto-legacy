extends Area2D
class_name Card

var card_data: CardData

func _ready():
	add_to_group("is_card") # Este grupo nunca será removido
	add_to_group("cards")   # Este é o grupo que permite arrastar
	
	# Conecta os sinais para o efeito de levantar a carta
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

# Esta função preenche a carta visual com os dados do Resource
func setup(data: CardData):
	card_data = data
	# Agora precisamos incluir "Visuals/" no caminho dos nós
	$Visuals/Artwork.texture = card_data.artwork
	$Visuals/NameLabel.text = card_data.card_name
	$Visuals/CostLabel.text = str(card_data.cost)
	$Visuals/DescriptionLabel.text = card_data.description

# --- LÓGICA DO EFEITO DE LEVANTAR (HOVER) ---

func _on_mouse_entered():
	# SÓ levanta se o pai da carta for a mão do jogador
	# (Isso impede o efeito quando a carta está na DropZone)
	if get_parent().name == "PlayerHand":
		animate_hover(-30.0)
		z_index = 10

func _on_mouse_exited():
	# Sempre tentamos voltar ao normal ao sair, para garantir que não fique "presa" no alto
	animate_hover(0.0)
	z_index = 0

func animate_hover(y_offset: float):
	# Verifica se a carta está sendo arrastada
	var card_manager = get_tree().get_first_node_in_group("card_manager_group")
	if card_manager and card_manager.card_being_dragged == self:
		return

	# Criamos o tween para mover apenas o container "Visuals"
	var tween = create_tween()
	# Isso moverá o container inteiro, mantendo a distância entre os textos e a imagem
	tween.tween_property($Visuals, "position:y", y_offset, 0.1).set_trans(Tween.TRANS_SINE)
	
func reset_visual():
	# Força o container Visuals a voltar para a posição original
	var tween = create_tween()
	tween.tween_property($Visuals, "position:y", 0.0, 0.1).set_trans(Tween.TRANS_SINE)
	z_index = 0
