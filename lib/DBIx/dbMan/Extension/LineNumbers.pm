package DBIx::dbMan::Extension::LineNumbers;

use strict;
use vars qw/$VERSION @ISA/;
use DBIx::dbMan::Extension;

$VERSION = '0.01';
@ISA = qw/DBIx::dbMan::Extension/;

1;

sub IDENTIFICATION { return "000001-000076-000001"; }

sub preference { return 30; }

sub known_actions { return [ qw/SQL_OUTPUT/ ]; }

sub handle_action {
	my ($obj,%action) = @_;

	$action{processed} = 1;
	if ($action{action} eq 'SQL_OUTPUT' and $obj->{-mempool}->get('line_numbers') and $obj->{-mempool}->get('output_format') ne 'insert') {
		my $i = 0;
		for my $line (@{$action{result}}) {
			$line = [ ++$i, @$line ];
		}
		$action{fieldnames} = [ '#', @{$action{fieldnames}} ];
		$action{fieldtypes} = [ -9999, @{$action{fieldtypes}} ];
	}

	return %action;
}
