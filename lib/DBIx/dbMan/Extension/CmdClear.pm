package DBIx::dbMan::Extension::CmdClear;

use strict;
use vars qw/$VERSION @ISA/;
use DBIx::dbMan::Extension;

$VERSION = '0.02';
@ISA = qw/DBIx::dbMan::Extension/;

1;

sub IDENTIFICATION { return "000001-000056-000002"; }

sub preference { return 1000; }

sub known_actions { return [ qw/COMMAND/ ]; }

sub handle_action {
	my ($obj,%action) = @_;

	if ($action{action} eq 'COMMAND') {
		if ($action{cmd} =~ /^clear(\s+screen)?$/i) {
			$action{action} = 'SCREEN';
			$action{operation} = 'clear';
		}
	}

	$action{processed} = 1;
	return %action;
}

sub cmdhelp {
	return [
		'CLEAR SCREEN' => 'Clear screen'
	];
}

sub cmdcomplete {
	my ($obj,$text,$line,$start) = @_;
	return qw/SCREEN/ if $line =~ /^\s*CLEAR\s+\S*$/i;
	return qw/CLEAR/ if $line =~ /^\s*[A-Z]*$/i;
	return ();
}
