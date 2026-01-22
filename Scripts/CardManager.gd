extends Node2D

var card_being_dragged = null
var is_dragging = false
var original_parent = null
var original_position = Vector2.ZERO

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
				original_parent = card.get_parent()
				original_position = card.position
				card_being_dragged.z_index = 100
				card_being_dragged.top_level = true
		elif is_dragging and card_being_dragged:
			var closest_zone = find_closest_zone()
			var gm = get_tree().get_first_node_in_group("game_manager")
			var card_played = false
			
			if closest_zone:
				# REGRA 1: VOLTAR PARA A MÃO (Mão agora é uma zona)
				if closest_zone.is_in_group("player_hand"):
					card_being_dragged.top_level = false
					if card_being_dragged.get_parent() != closest_zone:
						card_being_dragged.reparent(closest_zone)
					if not card_being_dragged.is_in_group("cards"):
						card_being_dragged.add_to_group("cards")
					card_played = true
				
				# REGRA 2: ZONA DE RECURSOS
				elif closest_zone.is_in_group("resource_zone"):
					if original_parent and (original_parent.is_in_group("player_hand") or "PlayerHand" in original_parent.name):
						card_being_dragged.top_level = false
						var container = closest_zone.get_node("ResourceContainer")
						card_being_dragged.reparent(container)
						create_tween().tween_property(card_being_dragged, "position", Vector2.ZERO, 0.2)
						if closest_zone.has_method("update_count"): closest_zone.update_count()
						card_being_dragged.remove_from_group("cards")
						card_played = true
					else:
						print("Apenas cartas da mão podem virar recurso!")
				
				# REGRA 3: OUTRAS ZONAS (Ataque, Defesa, Cemitério)
				else:
					card_being_dragged.top_level = false
					card_being_dragged.reparent(closest_zone)
					var target_pos = closest_zone.size / 2.0 if closest_zone is Control else Vector2.ZERO
					create_tween().tween_property(card_being_dragged, "position", target_pos, 0.2)
					card_being_dragged.remove_from_group("cards")
					card_played = true
			
			# SE NÃO FOI JOGADA COM SUCESSO -> VOLTA PARA A ORIGEM
			if not card_played:
				card_being_dragged.top_level = false
				if card_being_dragged.get_parent() != original_parent:
					card_being_dragged.reparent(original_parent)
				create_tween().tween_property(card_being_dragged, "position", original_position, 0.2)
				if original_parent.is_in_group("player_hand") or "PlayerHand" in original_parent.name:
					if not card_being_dragged.is_in_group("cards"): card_being_dragged.add_to_group("cards")

			# FINALIZAÇÃO
			card_being_dragged.z_index = 0
			if card_being_dragged.has_method("reset_visual"): card_being_dragged.reset_visual()
			is_dragging = false
			card_being_dragged = null
			if gm: gm.call_deferred("update_hand_positions")

func find_closest_zone():
	var closest = null
	var min_dist = 200.0
	for zone in get_tree().get_nodes_in_group("zone"):
		var center = zone.global_position + (zone.size / 2.0 if zone is Control else Vector2.ZERO)
		var dist = get_global_mouse_position().distance_to(center)
		if dist < min_dist:
			var occupied = false
			# Mão, Recurso e Cemitério podem ter várias cartas
			if not zone.is_in_group("resource_zone") and not zone.is_in_group("graveyard") and not zone.is_in_group("player_hand"):
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
		if obj.get_parent() and obj.get_parent().is_in_group("is_card"): return obj.get_parent()
	return null
