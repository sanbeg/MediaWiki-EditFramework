use Test::More;

BEGIN { use_ok('MediaWiki::EditFramework') };

ok(my $wiki = 'MediaWiki::EditFramework'->new('en.wikisource.org'));
isa_ok($wiki,'MediaWiki::EditFramework', 'framework is right class');

ok(my $page = $wiki->get_page('Main_Page'), 'got page');
isa_ok($page, 'MediaWiki::EditFramework::Page', 'page is right class');
ok($page->exists, 'page exists');

ok(my $bogus_page = $wiki->get_page('Test/w/index.php'));
ok(not($bogus_page->exists), "page doesn't exist");

done_testing;
