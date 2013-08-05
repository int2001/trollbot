#!/usr/bin/perl
use Net::Twitter;
use Data::Dumper;
use Scalar::Util 'blessed';
use Config::Tiny;
$|=1;

my $autoanswer=1;
my $retweeter=1;

use constant CONFIG_FILE => "/etc/trollbot.ini";
my $config = Config::Tiny->read(CONFIG_FILE);

# When no authentication is required:
my $nt = Net::Twitter->new(legacy => 0);

# As of 13-Aug-2010, Twitter requires OAuth for authenticated requests
my $nt = Net::Twitter->new(
	traits              => [qw/API::RESTv1_1/],
	consumer_key        => $config->{trollbot}->{consumer_key},
	consumer_secret     => $config->{trollbot}->{consumer_secret},
	access_token        => $config->{trollbot}->{token},
	access_token_secret => $config->{trollbot}->{token_secret},
);

if ($autoanswer) {
my @answers = ('Antwort 1', 'Antwort 2', '....');

# Fetch LastID from File

# Fetch Mentions from Twitter
my $mentions = $nt->mentions({since_id => $config->{trollbot}->{lastid}});
#print Dumper $mentions;
# Iterate fetched Mentions
foreach my $mention (reverse @$mentions) {

	$config->{trollbot}->{lastid} = $mention->{id};
	my $from     = $mention->{user}->{screen_name};
	my $arraypos = $config->{trollbot}->{lastid} % (($#answers) - 1);
	my $answer   = '@' . $from . ' ' . $answers[$arraypos];
	eval {my $result = $nt->create_favorite($config->{trollbot}->{lastid});};
	warn "FAV failed because: $@\n" if ($@);
	eval {my $result = $nt->update({in_reply_to_status_id => $config->{trollbot}->{lastid}, status => $answer});};
	warn "update failed because: $@\n" if ($@);
}


}

if ($retweeter) {
	my $bullshit=$nt->user_timeline({screen_name => $config->{trollbot}->{retweetname}, since_id => $config->{trollbot}->{lastret}});
	foreach my $shit (reverse @$bullshit) {
		$skip=0;
		$skip++ if ($shit->{entities}->{user_mentions}[0] ne '');
		$skip++ if ($shit->{in_reply_to_status_id} ne undef);
		$config->{trollbot}->{lastret}=$shit->{id};
		if ($skip == 0) {	
			print $shit->{id}.": ".$shit->{text}."\n";
			eval { $nt->update({status =>$shit->{text}}); };
			warn "update failed because: $@\n" if ($@);
		}
	}
}

# Write Last Mention-ID to file
$config->write(CONFIG_FILE);

# Errorhandling
if (my $err = $@) {
	die $@ unless blessed $err && $err->isa('Net::Twitter::Error');

	warn "HTTP Response Code: ", $err->code, "\n", "HTTP Message......: ", $err->message, "\n", "Twitter error.....: ", $err->error, "\n";
}

