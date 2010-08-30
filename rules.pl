use Irssi;
use strict;
use vars qw($VERSION %IRSSI);

$VERSION = "1.00";
%IRSSI = (
	authors     => 'Paul Traylor',
	name        => 'rules',
	description => 'Provides a !rules trigger',
	license     => ''
);

# Regex for the rules command
Irssi::settings_add_str($IRSSI{'name'}, 'cs_rules_keyword', '^!rules');
Irssi::settings_add_str($IRSSI{'name'}, 'cs_rules_url', '');

sub cmd_medic {
	Irssi::print('%G>>%n Rules can be configured with these settings:');
	Irssi::print('%G>>%n cs_watch         : This is the channel we watch for rules events.');
	Irssi::print('%G>>%n cs_rules_keyword : This is the regex we use to look for rules events.');
	Irssi::print('%G>>%n cs_rules_url     : This is the URL we send.');
}

sub sig_public {
	#"message public", SERVER_REC, char *msg, char *nick, char *address, char *target
	my ($server, $msg, $nick, $address, $target) = @_;
	
	# Only process if we actually have channels set
	# and our watched channel matches the target
	my $watch = Irssi::settings_get_str('cs_watch');
	return unless $watch ne '';
	return unless $target eq $watch;
	
	# Make sure we have a keyword string
	my $keyword = Irssi::settings_get_str('cs_rules_keyword');
	return unless $keyword ne '';
	
	my $url = Irssi::settings_get_str('cs_rules_url');
	# Doesn't make sense to continue if the URL is blank
	return unless $url ne ''; 
	
	if ($msg =~ /$keyword/) {
		$server->command("notice $nick $url")
	}
}

Irssi::signal_add('message public', 'sig_public');
Irssi::command_bind('rules', 'cmd_medic');

Irssi::print('%G>>%n '.$IRSSI{name}.' '.$VERSION.' loaded');
