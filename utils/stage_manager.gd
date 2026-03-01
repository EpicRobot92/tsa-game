extends Node

@export var start_level = -1
@export var can_pause = true

signal checkpoint_start
signal checkpoint_complete(checkpoint: Checkpoint)
signal stage_complete 
signal show_tutorial_prompt(step : int)
signal restart_stage
signal player_died
