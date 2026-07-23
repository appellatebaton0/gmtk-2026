extends Node

signal attempt_over

## The data for the current level.
var current_level:LevelData
var level_node:Node

## The timer for the attempt.
var attempt_timer := 0.:
	set(to):
		if attempt_timer > 0 and to <= 0:
			end_attempt()
			attempt_over.emit()
		attempt_timer = to
var attempt_index := -1 ## The index of the current attempt.
const ATTEMPT_LENGTH := 20.

const PLAYBACK_PLAYER_SCENE := preload("res://Scenes/PlaybackPlayer.tscn")

func _ready() -> void:
	## Hardcoded level, since I'll probably only have time to make one.
	current_level = LevelData.new()
	current_level.scene = preload("res://Scenes/Levels/Level1.tscn")

## Beginning an attempt. Load the scene, get the players all set up, y'know the deal.
func begin_attempt(index:int) -> void:
	attempt_timer = ATTEMPT_LENGTH
	attempt_index = index
	
	if level_node: level_node.queue_free()
	
	level_node = current_level.scene.instantiate()
	
	get_tree().root.get_child(1).add_child(level_node)
	
	var player := get_tree().get_first_node_in_group("Player") as Player
	
	for i in 5: ## There are 5 bodies. Hardcoded as well (yay...)
		
		if attempt_index == i: continue # Don't spawn the one being replaced. Ever.
		
		## If there's a recording for this body, spawn it.
		if current_level.attempts[i]:
		
			var new := PLAYBACK_PLAYER_SCENE.instantiate() as PlaybackPlayer
			
			new.record = current_level.attempts[i]
			
			level_node.add_child(new)
			
			new.global_position = player.global_position

func end_attempt() -> void:
	
	var player := get_tree().get_first_node_in_group("Player") as Player
	
	# Save the player's attempt into the level data.
	current_level.attempts[attempt_index] = player.record
	
	await get_tree().create_timer(0.5).timeout ## Wait half a second for the transition before freeing the level.
	
	level_node.queue_free()
	level_node = null

func _process(delta: float) -> void:
	attempt_timer = move_toward(attempt_timer, 0., delta)
	
	
