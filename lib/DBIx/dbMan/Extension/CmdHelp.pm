package DBIx::dbMan::Extension::CmdHelp;

use strict;
use vars qw/$VERSION @ISA/;
use DBIx::dbMan::Extension;

$VERSION = '0.05';
@ISA = qw/DBIx::dbMan::Extension/;

1;

sub IDENTIFICATION { return "000001-000009-000005"; }

sub preference { return 1000; }

sub known_actions { return [ qw/COMMAND/ ]; }

sub handle_action {
	my ($obj,%action) = @_;

	if ($action{action} eq 'COMMAND') {
		if ($action{cmd} =~ /^help(?:\s+(.+))?$/i) {
			$action{action} = 'HELP';
			$action{type} = 'commands';
			$action{what} = $1;
		} elsif ($action{cmd} =~ /^show\s+versions?$/i) {
			$action{action} = 'HELP';
			$action{type} = 'version';
		}
	}

	$action{processed} = 1;
	return %action;
}

sub cmdhelp {
	return [
		'HELP' => 'Show this help',
		'SHOW VERSION' => 'Show dbMan'."'".'s version'
	];
}

sub cmdcomplete {
	my ($obj,$text,$line,$start) = @_;
	return qw/VERSION/ if $line =~ /^\s*SHOW\s+[A-Z]*$/i;
	return qw/HELP SHOW/ if $line =~ /^\s*[A-Z]*$/i;
	return ();
}
