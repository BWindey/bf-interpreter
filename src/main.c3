module brainfuck;
import std::io;
import std::collections::map;

faultdef NO_MATCHING_BRACKET;

macro uint? find_closing(char[] instructions, uint i_idx) {
	uint parens_stack = 0;

	while (i_idx < instructions.len - 1) {
		i_idx++;
		if (instructions[i_idx] == '[') {
			parens_stack++;
		} else if (instructions[i_idx] == ']') {
			if (parens_stack == 0) return i_idx;
			parens_stack--;
		}
	}

	return NO_MATCHING_BRACKET?;
}

macro uint? find_opening(char[] instructions, uint i_idx) {
	uint parens_stack = 0;

	while (i_idx > 0) {
		i_idx--;
		if (instructions[i_idx] == ']') {
			parens_stack++;
		} else if (instructions[i_idx] == '[') {
			if (parens_stack == 0) return i_idx;
			parens_stack--;
		}
	}

	return NO_MATCHING_BRACKET?;
}

faultdef INCOMPLETE_FUNCTION;

fn uint? append_function(
	char[] instructions, uint i_idx, HashMap{char[], char[]}* map
) {
	uint name_start, name_end;
	uint body_start, body_end;

	// Find start of function name
	switch (instructions[i_idx]) {
		case 'a'..'z':
		case 'A'..'Z':
			name_start = i_idx;
			name_end = i_idx;
			i_idx++;
			if (i_idx >= instructions.len) return INCOMPLETE_FUNCTION?;
		default:
			i_idx++;
			nextcase instructions[i_idx];
	}

	// Find end of function name
	switch (instructions[i_idx]) {
		case 'a'..'z':
		case 'A'..'Z':
			i_idx++;
			if (i_idx >= instructions.len) return INCOMPLETE_FUNCTION?;
			nextcase instructions[i_idx];
		default:
			name_end = i_idx - 1;
	}

	if (i_idx >= instructions.len) return INCOMPLETE_FUNCTION?;

	body_start = i_idx;
	while (i_idx < instructions.len && instructions[i_idx] != '}') {
		i_idx++;
	}
	if (i_idx >= instructions.len) return INCOMPLETE_FUNCTION?;
	body_end = i_idx - 1;

	(*map)[instructions[name_start..name_end]] = instructions[body_start..body_end];

	return i_idx;
}

faultdef EXCEEDED_DATA;


fn void? interpret(
	char[] instructions,
	InStream stdin = io::stdin(),
	OutStream stdout = io::stdout(),
	char[] existing_data = {},
	uint* existing_d_idx = null,
	HashMap{char[], char[]}* existing_functions = {}
) {
	char[30000] _data;
	char[] data;
	uint d_idx = 0;
	uint i_idx = 0;

	HashMap{char[], char[]} functions;

	if (existing_data.len == 0) {
		data = &_data;
		functions.tinit();
	} else {
		data = existing_data;
		d_idx = *existing_d_idx;
		functions = *existing_functions;
	}

	while (i_idx < instructions.len) {
		switch (instructions[i_idx]) {
			case '>':
				if (d_idx < data.len) {
					d_idx++;
				} else {
					io::eprintn("Ran over end of data-array.");
					return EXCEEDED_DATA?;
				}
			case '<':
				if (d_idx > 0) {
					d_idx--;
				} else {
					io::eprintn("Ran over beginning of data-array.");
					return EXCEEDED_DATA?;
				}
			case '+':
				data[d_idx]++;
			case '-':
				data[d_idx]--;
			case '.':
				stdout.write_byte(data[d_idx])!;
				// If I want to debug:
				// io::printf("%c", data[d_idx]);
			case ',':
				data[d_idx] = stdin.read_byte()!;
			case '[':
				if (data[d_idx] == 0) {
					i_idx = find_closing(instructions, i_idx)!;
				}
			case ']':
				if (data[d_idx] != 0) {
					i_idx = find_opening(instructions, i_idx)!;
				}
			case '{':
				i_idx = append_function(instructions, i_idx, &functions)!;
			case 'a'..'z':
			case 'A'..'Z':
				uint name_start, name_end;
				name_start = i_idx;

				switch (instructions[i_idx]) {
					case 'a'..'z':
					case 'A'..'Z':
						i_idx++;
						if (i_idx >= instructions.len) return INCOMPLETE_FUNCTION?;
						nextcase instructions[i_idx];
					default:
						name_end = i_idx - 1;
				}
				char[] debug = instructions[name_start..name_end];
				interpret(
					functions[instructions[name_start..name_end]],
					stdin, stdout,
					data, &d_idx,
					&functions
				)!;
			i_idx--;
		}
		i_idx++;
	}

	if (existing_d_idx != null) *existing_d_idx = d_idx;
}

fn int main(String[] args)
{
	char[*] instructions = "++++++++++[>+>+++>+++++++>++++++++++<<<<-]>>>++.>+.+++++++..+++.<<++.>+++++++++++++++.>.+++.------.--------.";
	interpret(&instructions)!!;

	io::putchar('\n');
	return 0;
}
