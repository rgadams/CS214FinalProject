#!/usr/bin/perl
# m(0,1,4,6,7,8,11,12,15)
# The Tabular Method for simplifying boolean expressions.

use List::Util qw(first);

# An XOR Function that serves my purposes better than the built in one.
# It basically does a bitwise xor comparison of two strings.
sub ex_or{
	$first = @_[0];
	$second = @_[1];
	$numvars = @_[2];
	$xor = "";
	for($j=0; $j < $numvars; $j++) {
		if((substr $first, $j, 1) eq (substr $second, $j, 1)) {
			$xor .= "0";			
		}
		elsif((substr $first, $j, 1) ne (substr $second, $j, 1)) {
			$xor .= "1";	
		}
	}
	return $xor;
}

# Sorts the terms in order of number of 1's in the string.
# Also pads any terms with zeroes to make all the elements in @minterms
# have $numvars characters.
sub sort_terms{
	@minterms = @{@_[0]};
	$numvars = @_[1];
	@sorted_minterms;
	foreach $term (@minterms) { # Pad the numbers to give correct amount of zeroes.
		$padding = $numvars - length($term);
		if($padding > 0){
			for($i=0; $i < $padding; $i++) {
				$term = "0".$term;
			}
		}
	}
	for ($i=0; $i <= $numvars; $i++) { # Sort the terms in order of number of 1's
		foreach $term (@minterms) {
			$count = () = $term =~ /1/g;
			if($count == $i){
				push(@sorted_minterms, $term);
			}
		}
	}
	@minterms = @sorted_minterms;
}

# This takes all the terms in @minterms and compares them against one another
# to check for adjacency. If two terms are adjacent, they are combined into 
# one simpler term. If a term has no adjacencies, it is put in @finalized_minterms.
sub compare_terms{
	@minterms = @{@_[0]};
	$numvars = @_[1];
	@finalized_minterms = @{@_[2]};
	undef(@new_minterms);
	$new_term;
	foreach $term1 (@minterms) {
		$adjacency = 0;
		foreach $term2 (@minterms) {
			$new_term = "";
			if($term1 != $term2) {
				$xor = ex_or($term1, $term2, $numvars);
				$num_differences = () = $xor =~ /1/g;
				if($num_differences == 1) {
					$difference_index = index($xor, "1"); #index of the difference
					for($i=0; $i < $numvars; $i++) {
						if($i == $difference_index) {
							$new_term .= "-";
						}
						else {
							$new_term .= substr($term1, $i, 1);
						}
					}
					if(!first { $_ eq $new_term } @new_minterms) {
						push(@new_minterms, $new_term);
					}
					$adjacency = 1;
				}
			}
		}
		if($adjacency == 0) {
			push(@finalized_minterms, $term1);
		}
	}
	@minterms = @new_minterms;
}

# This subprogram takes the minterms given and turns them into prime implicants.
sub prime_implicants{
	@minterms = @{@_[0]}; # Dereference the list of minterms.
	foreach $term (@minterms) {
		$term = sprintf("%b", $term); # Convert terms to binary
	}
	sort_terms(\@minterms, @_[1]); # Sort and pad @minterms
	@finalized_minterms;
	# The tabular method states that after n-1 iterations (where n
	# is the number of variables) the equation is broken down into
	# prime implicants
	for($n=0; $n < @_[1]; $n++) {
		compare_terms(\@minterms, @_[1], \@finalized_minterms);
	}
	return @finalized_minterms;
}

# Creates a cover table for prime implicants, and figures out which ones are essential.
sub essential_prime_implicants{
	@prime_implicants = @{@_[0]};
	@decimal_minterms = @{@_[1]};
	@table;
	# Generate the table
	for($i=0; $i < scalar @prime_implicants; $i++) {
		for($j=0; $j < scalar @decimal_minterms; $j++) {
			$number_ambiguities = () = $prime_implicants[$i] =~ /\-/g;
			if($number_ambiguities > 0) {
				for($k=0; $k < 2**$number_ambiguities; $k++) {
					$k_binary = sprintf("%b", $k);
					$dummy_term = $prime_implicants[$i];
					$offset = 0;
					$count = 0;
					$position;
					while(1) {
						$position = index($dummy_term, "-", $offset);
						last if( $position < 0 );
						substr($dummy_term, $position, 1) = substr($k_binary, $count, 1);
						$offset = $position + 1;
						$count++;
					}
					if($decimal_minterms[$j] == oct("0b".$dummy_term)) {
						$table[$i][$j] = 1;
					}
					else {
						if($table[$i][$j] != 1) {
							$table[$i][$j] = 0;
						}
					}
				}
			}
			else {
				if($decimal_minterms[$j] == oct("0b".$prime_implicants[$i])) {
					$table[$i][$j] = 1;
				}
				else {
					$table[$i][$j] = 0;
				}
			}
		}
	}
	
	# Print the Cover Table, nicely formatted.
	print "\n  COVER TABLE:\n";
	print "  ";
	for($k=0; $k < length($prime_implicants[0]); $k++) {
		print " ";
	}
	print "  ";
	for($j=0; $j < scalar @decimal_minterms; $j++) {
		if(length("$decimal_minterms[$j]") == 1) {
			print "   "
		}
		else {
			print "  ";
		}
		print "$decimal_minterms[$j]  ";
	}
	print "\n";
	for($i=0; $i < scalar @prime_implicants; $i++) {
		print "  $prime_implicants[$i]  ";
		for($j=0; $j < scalar @decimal_minterms; $j++) {
			print "|  $table[$i][$j]  ";
		}
		print "|\n";
	}
	# End of Printing Cover Table

	# Determine Essential and Non-Essential Prime Implicants
	@epis;
	for($j=0; $j < scalar @decimal_minterms; $j++) {
		$epi_counter = 0;
		$epi = "";
		for($i=0; $i < scalar @prime_implicants; $i++) {
			if($table[$i][$j] == 1) {
				$epi_counter++;
				$epi = $prime_implicants[$i];
			}
		}
		if($epi_counter == 1) { # If there is only one PI in the column
			if(!first { $_ eq $epi } @epis) { # If the EPI doesn't exist in @epis yet
				push(@epis, $epi);
			}
		}
	}
	@non_epis;
	for($i=0; $i < scalar @prime_implicants; $i++) {
		if(!first { $_ eq $prime_implicants[$i] } @epis ) { # If the PI is not a EPI
			push(@non_epis, $prime_implicants[$i]);
		}
	}
	print "\n";
	foreach $epis (@epis) {
		print "$epis\n";
	}
	print "-------------\n";
	foreach $nepis (@epis) {
		print "$nepis\n";
	}
}

print "Please enter the min-string of the boolean expression:\n";
$minstring = <>; # Read the minstring
print "Please enter the number of variables in the expression:\n";
$numvars = <>; # Read the number of variables
substr $minstring, -1, 1, ""; # Remove the newline character at end of string
if((substr $minstring, 0, 2) == "m(" and (substr $minstring, -1) == ")") {
	substr $minstring, -1, 1, ""; # Remove ) char at end of string
	$termstring = substr $minstring, 2; # Remove m( at beginning of string
	@minterms = split(',', $termstring);
	@decimal_minterms = @minterms;
	@prime_implicants = prime_implicants(\@minterms, $numvars);
	essential_prime_implicants(\@prime_implicants, \@decimal_minterms);

} else {
    print "Not a min-string!";
}
