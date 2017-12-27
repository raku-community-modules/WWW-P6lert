unit class WWW::P6lert;
use WWW;
use Subset::Helper;

has $.api-url = 'https://alerts.perl6.org/api/v1';

role X is Exception {}
class X::NotFound does WWW::P6lert::X is Exception {
    method message { 'Alert not found' }
}
class X::Network  does WWW::P6lert::X is Exception {
    method message { 'P6lert API network error occured' }
}
sub err ($_) {
    .exception.message.starts-with('Error 404')
        ?? WWW::P6lert::X::NotFound.new
        !! WWW::P6lert::X::Network.new
}

class Alert {
    trusts WWW::P6lert;

    subset Severity of Str where subset-is * ∈ <info  normal  critical>,
        'Invalid alert severity value. Must be one of <info  normal  critical>';

    has UInt:D     $.id       is required;
    has Str:D      $.alert    is required;
    has UInt:D     $.time     is required;
    has Str:D      $.creator  is required;
    has Str:D      $.affects  is required;
    has Severity:D $.severity is required;

    method  new { X::Cannot::New: :class(::?CLASS) }
    method !new { self.bless: %_ }
    method time-human {
        DateTime.new($!time).Date
    }
    method alert-short {
        $!alert.chars > 60 ?? $!alert.substr(0, 60) ~ ' […]' !! $!alert;
    }
}


method all {
    (jget "$!api-url/all"
        orelse fail .&err)<alerts>.map: { WWW::P6lert::Alert!new: |$_ }
}
multi method since (DateTish $time) {
    (jget "$!api-url/since/" ~ $time.DateTime.Instant.to-posix.head.Int
        orelse fail .&err)<alerts>.map: { WWW::P6lert::Alert!new: |$_ }
}
multi method since (UInt $time) {
    (jget "$!api-url/since/$time"
        orelse fail .&err)<alerts>.map: { WWW::P6lert::Alert!new: |$_ }
}
method alert (UInt $id) {
    (jget "$!api-url/alert/$id"
        orelse fail .&err)<alerts>.map: { WWW::P6lert::Alert!new: |$_ }
}
