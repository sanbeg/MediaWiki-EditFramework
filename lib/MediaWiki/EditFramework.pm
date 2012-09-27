=head1 NAME

MediaWiki::EditFramework - a framework for editing MediaWiki pages.

=head1 SYNOPSIS

use MediaWiki::EditFramework;

my $wiki = MediaWiki::EditFramework->new('example.com', 'wiki');

=head2 DESCRIPTION

This is a higher level framework for editing MediaWiki pages.

=cut

package MediaWiki::EditFramework;

use strict;
use warnings;

use Carp;
use MediaWiki::API;
use Data::Dumper;
use MediaWiki::EditFramework::Page;
use strict;

our $VERSION = '0.01';
our ABSTRACT = 'framework for editing MediaWiki pages';

=head2 CONSTRUCTOR

=over

=item MediaWiki::EditFramework->B<new>(I<SITE>,I<PATH>)

Create a new instance pointing to the specified I<SITE> and I<PATH> (default
I<w>).  Creates the underling api object, pointing to
I<http://SITE/PATH/api.php>.

=back

=head2 METHODS

=over

=cut

sub new ($;$$) {
    my ($class,$site,$path)=@_;
    my $mw = MediaWiki::API->new();
    if (defined $site) {
	$path = 'w' unless defined $path;
	$mw->{config}->{api_url} = "http://$site/$path/api.php";
    }
    #$mw->{ua}->cookie_jar({file=>"$ENV{HOME}/.cookies.txt", autosave=>1});
    bless {0=>$mw, write_prefix=>''}, $class;
}

=item B<cookie_jar>(I<FILE>) 

Passes I<FILE> to L<LWP::UserAgent>'s I<cookie_jar> method, to store cookies
for a persistent login.

=cut

sub cookie_jar( $$ ) {
    #temporary method for persistent login.
    my $self = shift;
    my $file = shift;
    $self->{0}{ua}->cookie_jar($file, autosave=>1);
}

=item B<login>(I<$user>,I<$pass>)

Log in the specified user.

=cut

sub login ($$$) {
    my ($self,$user,$pass) = @_;
    my $mw = $self->{0};

    my $state = $mw->api({ action=>'query', meta=>'userinfo', });
    
    if (
	 ! exists $state->{query}{userinfo}{anon}
	and
	$state->{query}{userinfo}{name} eq $user
	){ 
	warn "already logged in as $user";
    } else {
	$mw->login( { lgname => $user, lgpassword => $pass } )
	    or confess $mw->{error}->{code} . ': ' . 
	    Dumper($mw->{error}->{details});
    }
}


sub get_text( $$ ) {
    my ($self,$title) = @_;
    my $page = $self->{0}->get_page({title=>$title});
    return $page->{'*'};
    #FIXME - store $page->{timestamp}, to pass back in
    # edit (basetimestamp=>$ts,..)

};

=item B<get_page>(I<TITLE>)

Get the wiki page with the specified I<TITLE>.  Returns an instance of
I<MediaWiki::EditFramework::Page>, which has methods to get/edit the page.

=cut

sub get_page( $$ ) {
    MediaWiki::EditFramework::Page->new(@_);
};

=item B<create_page>(I<TITLE>)

Get the wiki page with the specified I<TITLE>; then croak if it already
exists.

=cut

sub create_page( $$ ) {
    my $page = MediaWiki::EditFramework::Page->new(@_);
    croak "$_[1]: exists" if $page->exists;
    return $page;
};


sub write_prefix {
    my $self = shift;
    my $prefix = shift;
    $self->{write_prefix} = $prefix;
}

=back

=head1 SEE ALSO

L<MediaWiki::API>

=cut

1;
