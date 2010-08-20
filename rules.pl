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
Irssi::settings_add_str($IRSSI{'name'}, 'rules_keyword', '^!rules');
Irssi::settings_add_str($IRSSI{'name'}, 'rules_url', '');

sub sig_public {
	#"message public", SERVER_REC, char *msg, char *nick, char *address, char *target
	my ($server, $msg, $nick, $address, $target) = @_;
	
	# Make sure we have a keyword string
	my $keyword = Irssi::settings_get_str('rules_keyword');
	return unless $keyword ne '';
	
	my $url = Irssi::settings_get_str('rules_url');
	# Doesn't make sense to continue if the URL is blank
	return unless $url ne ''; 
	
	if ($msg =~ /$keyword/) {
		$server->command("notice $nick $url")
	}
}

Irssi::signal_add('message public', 'sig_public');

Irssi::print('%G>>%n '.$IRSSI{name}.' '.$VERSION.' loaded');
