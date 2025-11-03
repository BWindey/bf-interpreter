module brainfuck;
import std::io;

faultdef NO_MATCHING_BRACKET;

macro uint? find_closing(char[] instructions, uint i_idx) {
	uint parens_stack = 0;

	while (i_idx < instructions.len) {
		i_idx++;
		if (i_idx == 0) {
			break;
		} else if (instructions[i_idx] == '[') {
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
		if (i_idx == 0) {
			break;
		} else if (instructions[i_idx] == ']') {
			parens_stack++;
		} else if (instructions[i_idx] == '[') {
			if (parens_stack == 0) return i_idx;
			parens_stack--;
		}
	}

	return NO_MATCHING_BRACKET?;
}

faultdef EXCEEDED_DATA;

fn void? interpret(char[] instructions, InStream stdin = io::stdin(), OutStream stdout = io::stdout()) {
	char[30000] data;
	uint d_idx = 0;
	uint i_idx = 0;

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
