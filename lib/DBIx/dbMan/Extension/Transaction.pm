package DBIx::dbMan::Extension::Transaction;

use strict;
use vars qw/$VERSION @ISA/;
use DBIx::dbMan::Extension;

$VERSION = '0.02';
@ISA = qw/DBIx::dbMan::Extension/;

1;

sub IDENTIFICATION { return "000001-000022-000002"; }

sub preference { return 0; }

sub init {
	my $obj = shift;
	$obj->{prompt_num} = $obj->{-interface}->register_prompt(1000);
}

sub handle_action {
	my ($obj,%action) = @_;

	if ($action{action} eq 'TRANSACTION') {
		if ($action{operation} =~ /^(begin|end|commit|rollback)$/) {
			$action{action} = 'NONE';
			unless ($obj->{-dbi}->current) {
				$obj->{-interface}->error("No current connection selected.");
				return %action;
			}
			if ($obj->{-dbi}->in_transaction and $action{operation} eq 'begin') {
				$obj->{-interface}->error('Transaction already started.');
				return %action;
			} elsif (not $obj->{-dbi}->in_transaction and $action{operation} =~ /^(end|commit|rollback)$/) {
				$obj->{-interface}->error('No transaction started.');
				return %action;
			}

			if ($action{operation} eq 'begin') {
				$obj->{-dbi}->trans_begin;
				$action{output} = "Transaction started.\n";
			} elsif ($action{operation} eq 'end') {
				$obj->{-dbi}->rollback;
				$obj->{-dbi}->trans_end;
				$action{output} = "Auto commit transaction mode started with implicit rollback.\n";
			} elsif ($action{operation} eq 'commit') {
				$obj->{-dbi}->commit;
				$action{output} = "Transaction commited.\n";
			} elsif ($action{operation} eq 'rollback') {
				$obj->{-dbi}->rollback;
				$action{output} = "Transaction rolled back.\n";
			}
			$action{action} = 'OUTPUT';
		}
	}

	if ($obj->{-dbi}->in_transaction) {
		$obj->{-interface}->prompt($obj->{prompt_num},'TRANSACTION');
	} else {
		$obj->{-interface}->prompt($obj->{prompt_num},'');
	}

	$action{processed} = 1;
	return %action;
}

sub done {
	my $obj = shift;

	for (@{$obj->{-dbi}->list('active')}) {
		my $name = $_->{name};
		$obj->{-dbi}->be_quiet(1);
		$obj->{-dbi}->set_current($name);
		$obj->{-dbi}->be_quiet(0);
		if ($obj->{-dbi}->in_transaction()) {
			$obj->{-dbi}->rollback;
			$obj->{-dbi}->trans_end;
			$obj->{-interface}->print("Transaction end with implicit rollback in connection $name.\n");
		}
	}
}
