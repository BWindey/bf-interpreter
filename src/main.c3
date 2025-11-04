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

fn uint? fill_in_function(
	char[] instructions,
	uint i_idx,
	HashMap{char[], String}* map,
	DString* builder
) {
	uint start_name = i_idx;

	switch (instructions[i_idx]) {
		case 'a'..'z':
		case 'A'..'Z':
			i_idx++;
			nextcase instructions[i_idx];
	}
	i_idx--;

	String function_body = (*map)[instructions[start_name..i_idx]]!;
	builder.append_chars(function_body);

	return i_idx;
}

fn char[]? find_func_name(char[] instructions, uint* i_idx) {
	uint name_start, name_end;

	// Find start of function name
	switch (instructions[*i_idx]) {
		case 'a'..'z':
		case 'A'..'Z':
			name_start = *i_idx;
			name_end = *i_idx;
			(*i_idx)++;
			if (*i_idx >= instructions.len) return INCOMPLETE_FUNCTION?;
		default:
			(*i_idx)++;
			nextcase instructions[*i_idx];
	}

	// Find end of function name
	switch (instructions[*i_idx]) {
		case 'a'..'z':
		case 'A'..'Z':
			(*i_idx)++;
			if (*i_idx >= instructions.len) return INCOMPLETE_FUNCTION?;
			nextcase instructions[*i_idx];
		default:
			name_end = *i_idx - 1;
	}

	return instructions[name_start..name_end];
}

fn char[]? find_func_body(char[] instructions, uint* i_idx) {
	uint body_start = *i_idx;

	while (*i_idx < instructions.len && instructions[*i_idx] != '}') {
		(*i_idx)++;
	}
	if (*i_idx >= instructions.len) return INCOMPLETE_FUNCTION?;
	uint body_end = *i_idx - 1;

	return instructions[body_start..body_end];
}

fn void? resolve_func(
	char[] name, char[] body,
	HashMap{char[], String}* functions, DString* builder
) {
	DString func_builder;
	func_builder.tinit();

	for (uint i = 0; i < body.len; i++) {
		switch (body[i]) {
			case 'a'..'z':
			case 'A'..'Z':
				i = fill_in_function(body, i, functions, &func_builder)!;
			default:
				func_builder.append_char(body[i]);
		}
	}

	(*functions)[name] = func_builder.tcopy_str();
}

fn String? tpreprocess_instructions(char[] instructions) {
	DString builder;
	builder.tinit();
	HashMap{char[], String} functions;
	bool in_comment;

	for (uint i = 0; i < instructions.len; i++) {
		if (in_comment && instructions[i] != '#') continue;

		switch (instructions[i]) {
			case '#':
				in_comment = !in_comment;
			case '{':
				char[] func_name = find_func_name(instructions, &i)!;
				char[] func_body = find_func_body(instructions, &i)!;
				resolve_func(func_name, func_body, &functions, &builder)!;
			case 'a'..'z':
			case 'A'..'Z':
				i = fill_in_function(instructions, i, &functions, &builder)!;
			default:
				builder.append_char(instructions[i]);
		}
	}

	return builder.str_view();
}

faultdef EXCEEDED_DATA;

fn void? interpret(
	char[] instructions,
	InStream stdin = io::stdin(),
	OutStream stdout = io::stdout(),
) {
	char[30000] data;
	uint d_idx, i_idx;

	String procd_ins = tpreprocess_instructions(instructions)!;

	while (i_idx < procd_ins.len) {
		switch (procd_ins[i_idx]) {
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
					i_idx = find_closing(procd_ins, i_idx)!;
				}
			case ']':
				if (data[d_idx] != 0) {
					i_idx = find_opening(procd_ins, i_idx)!;
				}
		}
		i_idx++;
	}
}

fn int main(String[] args)
{
	char[*] instructions = "++++++++++[>+>+++>+++++++>++++++++++<<<<-]>>>++.>+.+++++++..+++.<<++.>+++++++++++++++.>.+++.------.--------.";
	interpret(&instructions)!!;

	io::putchar('\n');
	return 0;
}
