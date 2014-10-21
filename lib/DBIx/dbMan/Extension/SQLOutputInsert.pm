package DBIx::dbMan::Extension::SQLOutputInsert;

use strict;
use vars qw/$VERSION @ISA/;
use DBIx::dbMan::Extension;

$VERSION = '0.01';
@ISA = qw/DBIx::dbMan::Extension/;

1;

sub IDENTIFICATION { return "000001-000070-000001"; }

sub preference { return 0; }

sub known_actions { return [ qw/SQL_OUTPUT/ ]; }

sub init {
	my $obj = shift;
	$obj->{-mempool}->register('output_format','insert');
}
 
sub done {
	my $obj = shift;
	$obj->{-mempool}->deregister('output_format','insert');
	if ($obj->{-mempool}->get('output_format') eq 'insert') {
		my @all_formats = $obj->{-mempool}->get_register('output_format');
		$obj->{-mempool}->set('output_format',$all_formats[0]) if @all_formats;
	}
}
	
sub handle_action {
	my ($obj,%action) = @_;

	$action{processed} = 1;
	if ($action{action} eq 'SQL_OUTPUT') {
		if ($obj->{-mempool}->get('output_format') eq 'insert') {
			my $begin = 'INSERT INTO new_table ('.join(',',@{$action{fieldnames}}).') VALUES (';
			my @types = @{$action{fieldtypes}};
			my @litp = ();  my @lits = ();
			my $output = 'CREATE TABLE new_table ('.join(',',map { my %th = %{$obj->{-dbi}->type_info(shift @types)}; my $cp = $th{CREATE_PARAMS};  $cp =~ s/max length|precision/$th{COLUMN_SIZE}/g; $cp =~ s/scale/$th{MINIMUM_SCALE}/g; push @litp,$th{LITERAL_PREFIX}||''; push @lits,$th{LITERAL_SUFFIX}||''; $_.' '.$th{TYPE_NAME}.($cp?"($cp)":'').($th{NULLABLE} == 1?'':' NOT NULL'); } @{$action{fieldnames}}).");\n";
			for (@{$action{result}}) {
				my @lp = @litp;  my @ls = @lits;
				$output .= $begin . join ',',map { defined($_)?(shift(@lp).$_.shift(@ls)):"NULL" } @$_;
				$output .= ");\n";
			}
			$action{action} = 'OUTPUT';
			$action{output} = $output;
			delete $action{processed};
		}
	}

	return %action;
}
