use Irssi;
use strict;
use vars qw($VERSION %IRSSI);

$VERSION = "1.00";
%IRSSI = (
	authors     => 'Paul Traylor',
	name        => 'joinscan',
	description => 'Run a /whois when a user /joins a channel',
	license     => ''
);

sub cmd_help {
	Irssi::print('%G>>%n Joinscan can be configured with these settings:');
	Irssi::print('%G>>%n scan_watch    : This is the channel we watch.');
	Irssi::print('%G>>%n scan_check    : These are the channels we look for.');
	Irssi::print('%G>>%n scan_alert    : This is who we alert.');
}

sub event_join {
	my ($server, $channel, $nick, $address) = @_;
	my $watch = Irssi::settings_get_str('scan_watch');
	# Empty Setting ?
	return if($watch eq '');
	# Ignore Self
	return if ($nick eq $server->{nick});
	# Check that this is a join in the channel
	# we're watching
	return if ($channel ne $watch);
	
	$server->redirect_event("whois", 1, $nick, 0, undef, {
		"event 319" => "redir whois",
		"" => "event empty" });
	$server->send_raw("WHOIS :".$nick);
}

sub event_whois {
	Irssi::signal_stop();
	my $check = Irssi::settings_get_str('scan_check');
	return if($check eq ''); # Empty Setting ?
	
	my $alert = Irssi::settings_get_str('scan_alert');
	return if($alert eq ''); # Empty Setting ?
	
	my ($server, $data) = @_;
	my ($nick, $chans) = $data =~ /([\S]+)\s:(.*)/;
	if($chans =~ "$check") {
		$server->command("notice $alert $nick is in $check")
	}
}

Irssi::command_bind('joinscan', 'cmd_help');
Irssi::signal_add('message join','event_join');
Irssi::signal_add('redir whois','event_whois');

# The channel we're watching
Irssi::settings_add_str($IRSSI{'name'}, 'scan_watch', '');
# The channel we're looking for
Irssi::settings_add_str($IRSSI{'name'}, 'scan_check', '');
# Who we're alerting
Irssi::settings_add_str($IRSSI{'name'}, 'scan_alert', '');

Irssi::print('%G>>%n '.$IRSSI{name}.' '.$VERSION.' loaded (/joinscan for help)');
