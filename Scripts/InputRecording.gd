class_name InputRecording extends Resource
## A recording of inputs the player gives, for later playback.

@abstract class InputRecord:
	## A recording of a single input, for later playback.
	
	var _name:String
	func get_name() -> String: return _name
	
	## The current value in the record. Used to figure out when the value has
	## changed via comparison.
	var record_value:Variant 
	
	## Listens for its input and records any changes. Relies on external timer.
	func listen(time:float) -> void:
		
		var current_value:Variant = _calculate_value()
		
		## Value's changed, push it.
		if current_value != record_value:
			
			# print(_name, " -> ", current_value)
			push_change(time, current_value)
			
			record_value = current_value
	
	## Plays back the recorded changes. Relies on external timer.
	## prepare_playback has to be ran before playback begins.
	var remaining_changes:Dictionary[float, Variant]
	func prepare_playback() -> void: 
		remaining_changes.clear()
		remaining_changes.assign(get_changes().duplicate(true))
	func playback(time:float) -> void:
		for itime in remaining_changes:
			if time > itime:
				_set_value(remaining_changes[itime])
				remaining_changes.erase(itime)
	
	## Calculates the value being recorded using _inputs. Not the same as get_value.
	@abstract func _calculate_value() -> Variant
	
	## Get a dict of when the value changes, and what it changes to.
	@abstract func get_changes() -> Dictionary[float, Variant]
	## Push a change to that dict.
	@abstract func push_change(key:float, value:Variant) -> void
	
	## The inputs used to figure out the value. Usually just one, but it's an
	## array to support multiple, for vectors.
	@warning_ignore("unused_private_class_variable")
	var _inputs:PackedStringArray
	
	## Get the current value of this input record.
	@abstract func get_value() -> Variant
	@abstract func _set_value(to:Variant) -> void

class VectorInputRecord extends InputRecord:
	
	func _calculate_value() -> Vector2:
		return Input.get_vector(_inputs[0],_inputs[1],_inputs[2],_inputs[3])
	
	var _changes:Dictionary[float, Vector2]
	func get_changes() -> Dictionary[float, Vector2]: return _changes
	func push_change(key:float, value:Variant) -> void: _changes[key] = value
	
	var _value:Vector2
	func get_value() -> Vector2: return _value
	func _set_value(to:Variant) -> void: _value = to

class JustPressedInputRecord extends InputRecord:
	
	func _calculate_value() -> bool:
		return Input.is_action_just_pressed(_inputs[0])
	
	var _changes:Dictionary[float, bool]
	func get_changes() -> Dictionary[float, bool]: return _changes
	func push_change(key:float, value:Variant) -> void: _changes[key] = value
	
	var _value:bool
	func get_value() -> bool: return _value
	func _set_value(to:Variant) -> void: _value = to

## Stores the inputs recorded as an Array of InputRecords
var input_bank:Array[InputRecord]
## The to-be-recorded inputs. Formatted as name:type:inputs
@export var input_ids:Array[String]
var recording_timer := 0.0

func _init(set_inputs:Array[String] = []) -> void:
	input_ids = set_inputs

## -- Recording -- ##

## Resets all the variables in prep for recording.
func begin_recording() -> void:
	input_bank.clear()
	
	## Create an input_bank out of the valid_inputs.
	for input_id in input_ids:
		input_bank.append(fabricate_input_record(input_id))
	
	recording_timer = 0.

## Turns an appropriately-formatted string into an input record.
func fabricate_input_record(from:String) -> InputRecord:
	
	var args := from.split(":")
	
	var name := args[0]
	var type := args[1]
	var inputs := args[2].split(",")
	
	var record:InputRecord
	match type:
		"Vec2": record = VectorInputRecord.new()
		"Just": record = JustPressedInputRecord.new()
	
	record._name = name
	record._inputs = inputs
	
	return record

## Records inputs. Meant to be ran in _process by its owner.
func listen(delta:float) -> void:
	
	## Pretty much just a wrapper and timer for the InputRecords.
	
	for input in input_bank:
		input.listen(recording_timer)
	
	recording_timer += delta

## -- Playback -- ##

## Resets all the variables in prep for playback.
func begin_playback() -> void:
	for input in input_bank: input.prepare_playback()
	
	recording_timer = 0.0

## Updates the playback values for all the inputs in input_bank.
func playback(delta:float) -> void:
	
	for input in input_bank:
		input.playback(recording_timer)
	
	recording_timer += delta

func get_input(name:String) -> InputRecord:
	for input:InputRecord in input_bank:
		if input.get_name() == name: return input
	return null
