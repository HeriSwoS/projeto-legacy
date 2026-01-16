# CardManager.gd
extends Node2D

var card_being_dragged: Area2D = null

func _input(event):
	if event.is_action_pressed("ui_accept"):
		# ... seu código para detectar o clique ...
		if card_being_dragged != null:
			get_viewport().set_input_as_handled() # <--- Diz à Godot para parar de processar este evento
		# 1. Cria um objeto de consulta de física
		var query = PhysicsPointQueryParameters2D.new()
		# 2. Define a posição da consulta para a posição do mouse
		query.position = get_global_mouse_position()
		# 3. Define quais tipos de corpos queremos detectar (apenas Area2D no nosso caso)
		query.collide_with_areas = true
		
		# 4. Executa a consulta no espaço 2D do mundo
		var result = get_world_2d().direct_space_state.intersect_point(query)
		# --- FIM DA CORREÇÃO ---

		if not result.is_empty():
			var collider = result[0].collider
			# Verificamos se o objeto que clicamos é uma carta (pertence ao grupo "cards")
			if collider.is_in_group("cards"):
				card_being_dragged = collider
				# Traz a carta para a frente para que ela seja desenhada sobre as outras
				card_being_dragged.z_index = 100 

	# Detecta quando o botão do mouse é solto
	if event.is_action_released("ui_accept"):
		if card_being_dragged != null:
			print("Soltou a carta: ", card_being_dragged.card_data.card_name)
			# Retorna a carta para sua camada original
			card_being_dragged.z_index = 0
			card_being_dragged = null

func _process(_delta):
	# Move a carta que está sendo arrastada para a posição do mouse
	if card_being_dragged != null:
		card_being_dragged.global_position = get_global_mouse_position()
