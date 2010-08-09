use Irssi;
use strict;
use vars qw($VERSION %IRSSI);

$VERSION = "1.00";
%IRSSI = (
	authors     => 'Paul Traylor',
	name        => 'medic',
	description => 'Alert a staff channel on a keyword',
	license     => ''
);

sub cmd_medic {
	Irssi::print('%G>>%n Medic can be configured with these settings:');
	Irssi::print('%G>>%n medic_watch   : This is the channel we watch for medic events.');
	Irssi::print('%G>>%n medic_keyword : This is the regex we use to look for medic events.');
	Irssi::print('%G>>%n medic_alert   : This is who we alert for medic events.');
}

# The channel we're watching
Irssi::settings_add_str($IRSSI{'name'}, 'medic_watch', '');
# Regex for the medic command
Irssi::settings_add_str($IRSSI{'name'}, 'medic_keyword', '^!medic');
# Who we're alerting
Irssi::settings_add_str($IRSSI{'name'}, 'medic_alert', '');

sub sig_public {
	#"message public", SERVER_REC, char *msg, char *nick, char *address, char *target
	my ($server, $msg, $nick, $address, $target) = @_;
	print 'sig_message_public';
	
	# Only process if we actually have channels set
	# and our watched channel matches the target
	my $watch = Irssi::settings_get_str('medic_watch');
	return unless $watch ne '';
	return unless $target eq $watch;
	
	# Make sure we have a keyword string
	my $keyword = Irssi::settings_get_str('medic_keyword');
	return unless $keyword ne '';
	
	if ($msg =~ /$keyword/) {
		my $alert = Irssi::settings_get_str('medic_alert');
		return unless $alert ne '';
		$server->command("notice $alert Medic from $nick in $target: $msg");
	}
}

Irssi::command_bind('medic', 'cmd_medic');
Irssi::signal_add('message public', 'sig_public');

Irssi::print('%G>>%n '.$IRSSI{name}.' '.$VERSION.' loaded (/medic for help)');
