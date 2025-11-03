module bf_test @test;

fn void function_test_sum() {
	char[] instructions = "{sumtwo[>+<-]>}+++>++++++<sumtwo.";
	test_helper(instructions, (char[]) { 9 }, binary: true);
}

fn void function_test_hello_world() {
	char[] instructions = "{ printhello ++++++++++ [>+>+++>+++++++>++++++++++<<<<-] >>>++.>+.+++++++..+++.<<++.>+++++++++++++++.>.+++.------.--------. <<<[->--->-------->----------<<<]>-->-------<<< } printhello printhello printhello ";
	test_helper(instructions, "Hello WorldHello WorldHello World");
}

fn void function_test_ascii() {
	char[] instructions = "{ ASCIIa +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ } { ASCIIb ASCIIa+ } { ASCIIc ASCIIb+ } { ASCIId ASCIIc+ } ASCIIb.>ASCIIa.<.";
	test_helper(instructions, "bab");
}
