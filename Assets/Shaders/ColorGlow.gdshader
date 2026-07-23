shader_type canvas_item;
// Replaces a certain color with another, assumedly glowing color.

uniform float threshold = 0.1;
uniform vec4 target_color:source_color;
uniform vec4 result_color:source_color;

float dist(vec4 a, vec4 b)
{
	return sqrt(
		(pow(a.r, 2) - pow(b.r, 2)) +
		(pow(a.g, 2) - pow(b.g, 2)) +
		(pow(a.b, 2) - pow(b.b, 2)) +
		(pow(a.a, 2) - pow(b.a, 2))
	);
}

void fragment() {
	if (dist(COLOR, target_color) <= threshold)
	{
		COLOR = result_color;
	}
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
