use lib <lib>;
use Test::When <online>;
use Testo;

plan 2;

use WWW::P6lert;
my $alert = WWW::P6lert.new: |(:api-url($_) with %*ENV<WWW_P6LERT_API_URL>);

is $alert, WWW::P6lert, '.new makes right object';

group '.all' => {
    (my $all := $alert.all).cache;
    is $all, Seq, 'returns Seq';
    is $all, *.so, '.all gives some alerts';
    is $all.all, WWW::P6lert::Alert, 'all items are WWW::P6lert::Alert objects';
}
is $alert.since(1514316067), *.so, '.since with old date gives some alerts';
is $alert.since(time + 999999), *.not, 'no alerts in .since with future date';
