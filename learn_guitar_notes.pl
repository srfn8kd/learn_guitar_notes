#!/usr/bin/perl
use strict;
use warnings;
use Time::HiRes qw(sleep);
use List::Util qw(shuffle);

#######################################################################
# Provided by srfn8kd on Github
# Use at your own risk and share with any other guitar players you know!
# Let's play!
#######################################################################

# Function to clear the screen
sub clear_screen {
    print "\033[2J";    # Clear the screen
    print "\033[H";     # Move the cursor to the top-left corner
}

# Adjust the note text for Siri's pronunciation
sub adjust_note_for_siri {
    my ($note) = @_;
    return $note eq 'A' ? 'eh' : $note;
}

sub main() {
    # Define standard tuning for a guitar with corresponding notes
    my %guitar_strings = (
        'E6' => ['E', 'F', 'G', 'A', 'B', 'C', 'D'],
        'A'  => ['A', 'B', 'C', 'D', 'E', 'F', 'G'],
        'D'  => ['D', 'E', 'F', 'G', 'A', 'B', 'C'],
        'G'  => ['G', 'A', 'B', 'C', 'D', 'E', 'F'],
        'B'  => ['B', 'C', 'D', 'E', 'F', 'G', 'A'],
        'E1' => ['E', 'F', 'G', 'A', 'B', 'C', 'D']
    );

    # Map integers to strings
    my %string_map = (
        1 => 'E6',
        2 => 'A',
        3 => 'D',
        4 => 'G',
        5 => 'B',
        6 => 'E1'
    );

    # Display available strings and corresponding integers
    clear_screen();
    print "Choose strings to include:\n";
    foreach my $num (sort keys %string_map) {
        print "$num: $string_map{$num}\n";
    }

    # Ask user to select strings by entering integers
    print "Enter the integers corresponding to the strings you want to include (separated by spaces): ";
    my $string_input = <STDIN>;
    chomp($string_input);
    my @selected_integers = split /\s+/, $string_input;

    # Validate selected integers and map to strings
    my @selected_strings = map { $string_map{$_} } grep { exists $string_map{$_} } @selected_integers;
    if (!@selected_strings) {
        die "No valid strings selected. Exiting...\n";
    }

    # Collect notes for each selected string
    my %selected_notes;
    foreach my $string (@selected_strings) {
        clear_screen();
        my $notes = $guitar_strings{$string};
        print "Choose which notes to include for the $string string:\n";
        foreach my $i (1 .. @$notes) {
            print "$i: " . join(' ', @{$notes}[0 .. $i - 1]) . "\n";
        }
        print "Enter the integer corresponding to the number of notes to include for $string: ";
        my $note_choice = <STDIN>;
        chomp($note_choice);

        # Validate and select notes
        if ($note_choice =~ /^\d+$/ && $note_choice >= 1 && $note_choice <= @$notes) {
            $selected_notes{$string} = [ @{$notes}[0 .. $note_choice - 1] ];
        } else {
            print "Invalid choice for $string. Skipping...\n";
        }
    }

    # Check if there are any valid selections
    if (!%selected_notes) {
        die "No valid strings or notes selected. Exiting...\n";
    }

    print "Enter the delay time between each new note: ";
    my $delay_t = <STDIN>;
    chomp $delay_t;

    # Create a queue of string-note combinations
    my @queue = ();
    while (1) {
        # Rebuild and shuffle the queue if it's empty
        if (!@queue) {
            foreach my $string (shuffle @selected_strings) {
                my @notes = shuffle @{$selected_notes{$string}};
                foreach my $note (@notes) {
                    push @queue, { string => $string, note => $note };
                }
            }
        }

        # Dequeue the next string-note combination
        my $next = shift @queue;
        my $string = $next->{string};
        my $note = $next->{note};
        my $adjusted_note = adjust_note_for_siri($note);

        # Print and speak the combination
        my $output = "$string - $note";
        print "\r$output       ";  # Overwrite previous output
        system("say string $string note $adjusted_note");

        # Delay
        sleep($delay_t);
    }
}

main();

