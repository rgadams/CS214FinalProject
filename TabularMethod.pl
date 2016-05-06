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

sub prime_implicants{
	@minterms = @{@_[0]}; # Dereference the list of minterms.
	foreach $term (@minterms) {
		$term = sprintf("%b", $term); # Convert terms to binary
	}
	sort_terms(\@minterms, @_[1]);
	@finalized_minterms;
	#compare_terms(\@minterms, @_[1], \@finalized_minterms);
	#compare_terms(\@minterms, @_[1], \@finalized_minterms);
	#compare_terms(\@minterms, @_[1], \@finalized_minterms);
	for($n=0; $n < @_[1]; $n++) {
		compare_terms(\@minterms, @_[1], \@finalized_minterms);
	}
	foreach $term (@finalized_minterms) {
		print "$term\n";
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
	prime_implicants(\@minterms, $numvars); # Get the prime implicants of the expression

} else {
    print "Not a min-string!";
}



