# CS214FinalProject

This project implements the tabular method, which takes a minstring and outputs a cover table of the results of that minstring.

The method goes like this:
1. Read in the minstring from the command line and split it into the numbers within the string.
2. Convert all the numbers into binary strings, then sort those strings by the number of 1's in the string.
3. Compare all the strings against one another, if there is only one difference between the two strings we know
  the two binaries are adjacent.
4. For any adjacencies, swap the bit that is different with a "-" character.
5. Repeat steps 3-4 n times, where n is the number of variables/characters in each string.
6. For all the strings that are left, all are Prime Implicants.
7. Create a table with all the Prime Implicants as the rows and Decimal numbers from the minstring as the columns.
8. For each column in the table, if the bitstring correlates with one of the decimal representations, mark a one in the column.
  Otherwise, mark a zero.
9. If there is only one one in a column, the row with that one represents an essential prime implicant. All the prime implicants
  that are not essential are non-essential. Using the essential and non-essential prime implicants we can determine the final 
  boolean expression.
