class_name InputRecording extends Resource
## A recording of inputs the player gives, for later playback.

## Stores the inputs recorded as time:input (multiple inputs delimited by ,)
@export var input_record:Dictionary[float, String]
## The allowed-to-be-recorded inputs.
@export var valid_inputs:Array[String]
var recording_timer := 0.0

## -- Recording -- ##

## Resets all the variables in prep for recording.
func begin_recording() -> void:
	input_record.clear()
	recording_timer = 0.

## Records inputs. Meant to be ran in _process by its owner.
func listen(delta:float) -> void:
	
	var should_record := false ## Stays false if none pressed, and doesn't log anything.
	var record := ""
	
	for input in valid_inputs:
		if Input.is_action_just_pressed(input):
			
			if record != "": record += "," ## Not the first input, needs a delimiter.
			
			record += input ## Mark this input for recording
			
			should_record = true
	
	# Got something to record? THEN DO IT.
	if should_record:
		input_record[recording_timer] = record
		
	
	recording_timer += delta

## -- Playback -- ##

## Stores any inputs that haven't been played, to stop them
## from being played again this go-around.
var waiting_inputs:Dictionary[float,String]

## Resets all the variables in prep for playback.
func begin_playback() -> void:
	waiting_inputs = input_record.duplicate()
	recording_timer = 0.0

## Responds with all the inputs to play in a frame, as an array.
func playback(delta:float) -> PackedStringArray:
	
	if waiting_inputs.size() == 0: return PackedStringArray([])
	
	var response := PackedStringArray([])
	
	for input:float in waiting_inputs:
		## If this input should be played this frame, add it to the response.
		if recording_timer >= input:
			response += waiting_inputs[input].split(",")
	
	recording_timer += delta
	
	return response
