=head1 NAME

MediaWiki::EditFramework::Page - an object to represent a MediaWiki page.

=head1 SYNOPSIS

 use MediaWiki::EditFramework;

 my $wiki = MediaWiki::EditFramework->new('example.com', 'wiki');
 my $page = $wiki->get_page('Main_Page');
 my $text = $page->get_text;
 $text =~ s/old thing/new update/g;
 $page->edit($text, 'update page');

=head1 DESCRIPTION

This module represents a MediaWiki page.  When instantiated, it gets the
page information from the site.  The last modified timestamp is stored when
the page is retrieved, and based back with the I<edit> method, to allow the
server to properly detect edit conflicts.

=head2 METHODS

=over

=cut

package MediaWiki::EditFramework::Page;
use strict;
use warnings;	
use Data::Dumper;


sub new ($$$) {
	my ($class,$api,$title) = @_;
	my $page = $api->{0}->get_page({title=>$title});
	bless [$api,$page], $class;
}

=item B<get_text>

Get the current page text.

=cut

sub get_text( $ ) {
	return $_[0][1]{'*'};
}

=item B<edit>(I<TEXT>,I<SUMMARY>)

Replace the text of the page with the specified I<TEXT>.  Using the
specified I<SUMMARY> as the edit summary to describe the edit.

The original timestamp will be passed back; if the page was editing between
when it was retrieved and when edit is called, and the server cannot
automatically merge our edit, then the edit will be rejected in order to
prevent clobbering the other edit.

If the L<MediaWiki::EditFramework> object has an I<edit_prefix> in effect,
that will be prepended to the page name.  This allow redirecting the output
from an edit into user space, to facilitate testing bot code.

=cut

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
    
=item B<exists>

Returns true if the underlying page existed on the server when the page was
rretrieved, false if it is a new page.

=cut

sub exists {
	my ($self) = @_;
	return exists $self->[1]->{'*'};
}


1;
