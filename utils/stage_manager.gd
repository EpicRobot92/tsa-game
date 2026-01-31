extends Node

@export var start_level = 0

signal checkpoint_start
signal checkpoint_complete(checkpoint: Checkpoint)
signal stage_complete 
signal show_tutorial_prompt(step : int)
