use lib <lib>;
use Test::When <online>;
use Testo;

plan 5;

use WWW::P6lert;
my $alerts = WWW::P6lert.new: |(:api-url($_) with %*ENV<WWW_P6LERT_API_URL>);
is $alerts, WWW::P6lert, '.new makes right object';

group '.all' => {
    (my $all := $alerts.all).cache;
    is $all, Seq, 'returns Seq';
    is $all, *.so, '.all gives some alerts';
    is $all.all, WWW::P6lert::Alert, 'all items are WWW::P6lert::Alert objects';
}

group '.since' => 5 => {
    is $alerts.since(1514316067), *.so, '.since with old date gives some alerts';
    is $alerts.since(time + 999999), *.not, 'no alerts in .since with future date';

    group 'UInt time' => 3 => {
        (my $since := $alerts.since: 1514316067).cache;
        is $since, Seq, 'returns Seq';
        is $since, *.so, '.all gives some alerts';
        is $since.all, WWW::P6lert::Alert, 'all items are WWW::P6lert::Alert objects';
    }

    group 'Date time' => 3 => {
        (my $since := $alerts.since: DateTime.new(1514316067).Date).cache;
        is $since, Seq, 'returns Seq';
        is $since, *.so, '.all gives some alerts';
        is $since.all, WWW::P6lert::Alert, 'all items are WWW::P6lert::Alert objects';
    }

    group 'DateTime time' => 3 => {
        (my $since := $alerts.since: DateTime.new: 1514316067).cache;
        is $since, Seq, 'returns Seq';
        is $since, *.so, '.all gives some alerts';
        is $since.all, WWW::P6lert::Alert, 'all items are WWW::P6lert::Alert objects';
    }
}

group '.last' => {
    is $alerts.last(2), 2, '.last(2) gives 2 alerts';
    is $alerts.last(1), 1, '.last(1) gives 1 alert';

    (my $last := $alerts.last: 10).cache;
    is $last, Seq, 'returns Seq';
    is $last, *.so, '.all gives some alerts';
    is $last.all, WWW::P6lert::Alert, 'all items are WWW::P6lert::Alert objects';
}

group '.alert' => 2 => {
    my @alerts := $alerts.last(2).List;
    my $alert1 = $alerts.get: @alerts.head.id;
    my $alert2 = $alerts.get: @alerts.tail.id;
    is-eqv $alert1, @alerts.head, "got right alert (ID  {@alerts.head.id})";
    is-eqv $alert2, @alerts.tail, "got right alert (ID  {@alerts.tail.id})";
}
