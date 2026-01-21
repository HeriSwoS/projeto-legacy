extends Node2D

var card_being_dragged = null
var is_dragging = false

func _process(_delta):
	if is_dragging and card_being_dragged:
		card_being_dragged.global_position = get_global_mouse_position()

func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var card = get_card_at_mouse()
			if card:
				card_being_dragged = card
				is_dragging = true
				card_being_dragged.z_index = 100
				card_being_dragged.top_level = true
				print("Iniciando arrasto de: ", card_being_dragged.card_data.card_name)
		elif is_dragging and card_being_dragged:
			# --- SOLTAR A CARTA ---
			print("Soltando carta: ", card_being_dragged.card_data.card_name)
			var closest_zone = find_closest_zone()
			var gm = get_tree().get_first_node_in_group("game_manager")
			
			print("GameManager encontrado: ", gm != null)
			print("Zona mais próxima encontrada: ", closest_zone != null)
			
			if closest_zone:
				# VERIFICAR SE É CEMITÉRIO
				if closest_zone.is_in_group("graveyard"):
					print("Colocando carta no CEMITÉRIO")
					card_being_dragged.top_level = false
					closest_zone.add_card(card_being_dragged)
					card_being_dragged.remove_from_group("cards")
				else:
					# JOGAR NA ZONA DE COMBATE (ATAQUE/DEFESA)
					print("Colocando carta em zona de combate")
					card_being_dragged.top_level = false
					card_being_dragged.reparent(closest_zone)
					var target_pos = closest_zone.size / 2.0 if closest_zone is Control else Vector2.ZERO
					create_tween().tween_property(card_being_dragged, "position", target_pos, 0.2)
					card_being_dragged.remove_from_group("cards")
			else:
				# VOLTAR PARA A MÃO
				print("Devolvendo carta para a mão")
				if gm:
					var hand_node = gm.get_node("PlayerHand")
					card_being_dragged.top_level = false
					if card_being_dragged.get_parent() != hand_node:
						card_being_dragged.reparent(hand_node)
					if not card_being_dragged.is_in_group("cards"):
						card_being_dragged.add_to_group("cards")
					
					# NOVO: Reorganiza a mão baseado na posição onde foi solta
					print("Verificando se GameManager tem método 'reorder_hand_by_position'")
					if gm.has_method("reorder_hand_by_position"):
						print("Chamando reorder_hand_by_position")
						gm.reorder_hand_by_position(card_being_dragged)
					else:
						print("ERRO: GameManager não tem o método 'reorder_hand_by_position'")
				else:
					print("ERRO: GameManager não foi encontrado!")

			# FINALIZAÇÃO
			card_being_dragged.z_index = 0
			if card_being_dragged.has_method("reset_visual"):
				card_being_dragged.reset_visual()
			
			is_dragging = false
			card_being_dragged = null
			
			if gm: gm.update_hand_positions()

func find_closest_zone():
	var closest = null
	var min_dist = 150.0
	for zone in get_tree().get_nodes_in_group("zone"):
		var center = zone.global_position + (zone.size / 2.0 if zone is Control else Vector2.ZERO)
		var dist = get_global_mouse_position().distance_to(center)
		if dist < min_dist:
			var occupied = false
			for child in zone.get_children():
				if child.is_in_group("is_card"): occupied = true
			if not occupied:
				min_dist = dist
				closest = zone
	return closest

func get_card_at_mouse():
	var query = PhysicsPointQueryParameters2D.new()
	query.position = get_global_mouse_position()
	query.collide_with_areas = true
	var results = get_world_2d().direct_space_state.intersect_point(query)
	for r in results:
		var obj = r.collider
		if obj.is_in_group("is_card"): return obj
		if obj.get_parent().is_in_group("is_card"): return obj.get_parent()
	return null
