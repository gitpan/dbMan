package DBIx::dbMan::Extension::EditObjects;

use strict;
use vars qw/$VERSION @ISA/;
use DBIx::dbMan::Extension;

$VERSION = '0.01';
@ISA = qw/DBIx::dbMan::Extension/;

1;

sub IDENTIFICATION { return "000001-000043-000001"; }

sub preference { return 0; }

sub handle_action {
	my ($obj,%action) = @_;

	$action{processed} = 1;
	if ($action{action} eq 'EDIT_OBJECT' and not $action{type}) {
		$action{action} = 'NONE';
		unless ($obj->{-dbi}->current) {
			$obj->{-interface}->error("No current connection selected.");
			return %action;
		}
		my $sth = $obj->{-dbi}->table_info({ TABLE_NAME => $action{what} });
		unless (defined $sth) {
			$obj->{-interface}->error("Object ".$action{what}." not found.");
			return %action;
		}
		my $ret = $sth->fetchall_arrayref();
		unless (defined $ret) {
			$sth->finish;
			$obj->{-interface}->error("Object ".$action{what}." not found.");
			return %action;
		}
		$sth->finish;
		my $found = 0;
		my $type = '';
		for (@$ret) {
			if ($_->[2] eq $action{what}) {
				$type = $_->[3];  ++$found;
			}
		}
		unless ($found) {
			$obj->{-interface}->error("Object ".$action{what}." not found.");
			return %action;
		}
		$action{type} = $type;
		$action{action} = 'EDIT_OBJECT';
		delete $action{processed};
	}

	return %action;
}
