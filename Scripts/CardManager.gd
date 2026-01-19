extends Node2D

var card_being_dragged: Card = null
var original_parent: Node = null

@export var player_hand: Node2D
@export var game_manager: Node

func _ready():
	add_to_group("card_manager_group")

func _unhandled_input(event):
	# 1. PEGAR A CARTA
	if event.is_action_pressed("ui_accept"):
		if card_being_dragged == null:
			var query = PhysicsPointQueryParameters2D.new()
			query.position = get_global_mouse_position()
			query.collide_with_areas = true
			query.collision_mask = 1

			var result = get_world_2d().direct_space_state.intersect_point(query)

			if not result.is_empty():
				var collider = result[0].collider
				if collider is Card:
					card_being_dragged = collider
					original_parent = card_being_dragged.get_parent()
					
					# Trazemos a carta para o topo visualmente
					card_being_dragged.z_index = 100
					
					# Se a carta estava em uma zona, permitimos que ela seja arrastada de novo
					if original_parent.is_in_group("zone"):
						card_being_dragged.add_to_group("cards")
						# IMPORTANTE: Não reparentamos para a mão ainda! 
						# Apenas deixamos ela livre para seguir o mouse.

	# 2. SOLTAR A CARTA (Lógica para Múltiplas Zonas)
	if event.is_action_released("ui_accept"):
		if card_being_dragged != null:
			var card_played = false
			var snap_distance = 150.0
			
			# --- BUSCA A ZONA MAIS PRÓXIMA ---
			var closest_zone = null
			var min_dist = snap_distance
			var all_zones = get_tree().get_nodes_in_group("zone")
			
			for zone in all_zones:
				var dist = card_being_dragged.global_position.distance_to(zone.global_position)
				
				var is_occupied = false
				for child in zone.get_children():
					if child.is_in_group("is_card"):
						is_occupied = true
						break
				
				if dist < min_dist and not is_occupied:
					min_dist = dist
					closest_zone = zone

			# --- JOGAR NA ZONA ---
				if closest_zone != null:
					card_played = true
					card_being_dragged.reparent(closest_zone)
					
					# CALCULA O CENTRO: Metade do tamanho da zona
					var target_pos = Vector2.ZERO
					if closest_zone is Control:
						target_pos = closest_zone.size / 2.0
					
					var tween = create_tween()
					# Move para o centro calculado
					tween.tween_property(card_being_dragged, "position", target_pos, 0.2).set_trans(Tween.TRANS_CUBIC)
					
					card_being_dragged.remove_from_group("cards")
					card_being_dragged.z_index = 0
					if game_manager: game_manager.update_hand_positions()

			# --- VOLTAR PARA A MÃO (FALLBACK) ---
			if not card_played:
				card_being_dragged.reparent(player_hand)
				card_being_dragged.z_index = 0
				card_being_dragged.add_to_group("cards")
				if game_manager: game_manager.update_hand_positions()
			
			card_being_dragged.reset_visual()
			
			card_being_dragged = null

func _process(_delta):
	if card_being_dragged != null:
		card_being_dragged.global_position = get_global_mouse_position()
		
		# Reordenação em tempo real na mão
		if card_being_dragged.get_parent() == player_hand:
			var current_index = card_being_dragged.get_index()
			var hand_children = player_hand.get_children()
			for i in range(hand_children.size()):
				var other_card = hand_children[i]
				if other_card == card_being_dragged or not other_card.is_in_group("is_card"):
					continue
				var mouse_pos_local = player_hand.get_local_mouse_position()
				if mouse_pos_local.x < other_card.position.x and current_index > i:
					player_hand.move_child(card_being_dragged, i)
					if game_manager: game_manager.update_hand_positions()
					break
				elif mouse_pos_local.x > other_card.position.x and current_index < i:
					player_hand.move_child(card_being_dragged, i)
					if game_manager: game_manager.update_hand_positions()
					break
