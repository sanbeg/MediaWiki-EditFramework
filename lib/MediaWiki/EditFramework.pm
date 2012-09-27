package MediaWiki::EditFramework;

use strict;
use warnings;

use Carp;
use MediaWiki::API;
use Data::Dumper;

use strict;

our $VERSION = '0.01';

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

sub cookie_jar( $$ ) {
    #temporary method for persistent login.
    my $self = shift;
    my $file = shift;
    $self->{0}{ua}->cookie_jar($file, autosave=>1);
}

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

sub edit( $$$ ) {
    my ($self,$title,$text,$summary) = @_;
    my $mw = $self->{0};
    
    die "goodbye cruel world";

    $mw->edit({
	action=>'edit', bot=>1,
	title=>$title,
	text=>$text,
	summary=>$summary,
	}) or confess $mw->{error}->{code} . ': ' . 
	    Dumper($mw->{error}->{details});
}


sub get_page( $$ ) {
    MediaWiki::EditFramework::Page->new(@_);
};
sub create_page( $$ ) {
    my $page = MediaWiki::EditFramework::Page->new(@_);
    croak "$_[1]: exists" if $page->exists;
    return $page;
};


1;
