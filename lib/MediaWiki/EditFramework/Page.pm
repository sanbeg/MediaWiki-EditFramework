package MediaWiki::EditFramework::Page;
use strict;
use warnings;	
use Data::Dumper;

sub new ($$$) {
	my ($class,$api,$title) = @_;
	my $page = $api->{0}->get_page({title=>$title});
	bless [$api,$page], $class;
}

sub get_text( $$ ) {
	return $_[0]->[1]->{'*'};
}

sub edit( $$$ ) {
	my ($self,$text,$summary) = @_;
	my $mw = $self->[0];
	my $page = $self->[1];
	my $p = $mw->{write_prefix};

	my %qh = (
		action=>'edit', 
		bot=>1,
		title=>($p.$page->{title}),
		text=>$text,
		summary=>$summary,
	);

	$qh{basetimestamp}=$page->{timestamp} if $p eq '';

	eval {
		warn "edit $qh{title}";
		$mw->{0}->edit(\%qh) 
		  or croak $mw->{error}->{code} . ': ' . $mw->{error}->{details};
	};
	
	die "Edit failed: ". Data::Dumper::Dumper($@) if $@;
}
    
sub exists {
	my ($self) = @_;
	return exists $self->[1]->{'*'};
}


1;
