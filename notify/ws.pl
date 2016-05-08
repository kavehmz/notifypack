#!/usr/bin/env perl
use utf8;
use Mojolicious::Lite;
use DateTime;
use Mojo::Redis2;
use JSON::XS qw(encode_json);
use feature "state";
use Array::Diff;

sub package_changes {
    state $last = [split "\n", `dpkg -l|sort`];

    my $current = [split "\n", `dpkg -l|sort`];
    my $diff = Array::Diff->diff( $last, $current);

    return {installed=>$diff->added, removed=>$diff->deleted};
}

websocket '/' => sub {
    my $self = shift;

    state $conn = {};

	Mojo::IOLoop->singleton->stream($self->tx->connection)->timeout(600);
    my $id = sprintf "%s", $self->tx;
    $conn->{$id} = $self->tx;
 
    if (!$self->stash->{started}) {
        Mojo::IOLoop->recurring(5 => sub {
            my $loop = shift;
            my $dt   = DateTime->now( time_zone => 'Asia/Tokyo');
            for (keys %$conn) {
                $conn->{$_}->send({json => {
                    changes  => package_changes(),
                }});
            }
        });
        $self->stash->{started}=1
    }

    $self->on(message => sub {
        my ($self, $msg) = @_;
    });

    $self->on(finish => sub {
        app->log->debug('Client disconnected');
    });
};

app->start;
1;