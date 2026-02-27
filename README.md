# lab2
This program computes the Hamming distance (bit differences) between two strings using x86-64 assembly (GAS / AT&T syntax). It compares characters only up to the length of the shorter string. For each character position it XORs the two bytes and counts the number of 1 bits, then prints the total.

Compile:
gcc -no-pie -z noexecstack hamming_distance.s -o hamming

Run (interactive):
./hamming
Then enter the first string, press Enter, and enter the second string.

Run (test mode):
./hamming --test
This runs the built-in test cases and prints PASS/FAIL.

