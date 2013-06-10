#!/usr/bin/env perl
# vi: set sw=4 ts=4 ai:
# $Id: we-blog-log.pl 4 2013-04-10 11:25:17 tonk $

# we-blog-log - displays the We-Blog repository log
# Copyright (c) 2011-2012 Ton Kersten
# Copyright (c) 2009-2011 Jaromir Hradilek

# This program is  free software:  you can redistribute it and/or modify it
# under  the terms  of the  GNU General Public License  as published by the
# Free Software Foundation, version 3 of the License.
#
# This program  is  distributed  in the hope  that it will  be useful,  but
# WITHOUT  ANY WARRANTY;  without  even the implied  warranty of MERCHANTA-
# BILITY  or  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public
# License for more details.
#
# You should have received a copy of the  GNU General Public License  along
# with this program. If not, see <http://www.gnu.org/licenses/>.

use strict;
use warnings;
use File::Basename;
use File::Spec::Functions;
use Getopt::Long;
use Term::ANSIColor;
use Text::Wrap;

# Set the library path and use our own module
use lib dirname($0);
use We;

# Display usage information:
sub display_help {
	# Display the usage:
	print << "END_HELP";
Usage: $NAME [-cqrsCV] [-b DIRECTORY] [-n NUMBER]
			 $NAME -h|-v

	-b, --blogdir DIRECTORY     specify a directory in which the We-Blog
	                            repository is placed
	-n, --number NUMBER         specify a number of log entries to be listed
	-s, --short                 display each log entry on a single line
	-S, --stats                 display log statistics
	-r, --reverse               display log entries in reverse order
	-c, --color                 enable colored output
	-C, --no-color              disable colored output
	-q, --quiet                 do not display unnecessary messages
	-V, --verbose               display all messages
	-h, --help                  display this help and exit
	-v, --version               display version information and exit
END_HELP

	# Return success:
	return 1;
}

# Display a log entry:
sub display_record {
	my $record = shift || die 'Missing argument';

	# Check whether to use compact listing:
	unless ($compact) {
		# Decompose the record:
		my ($date, $message) = split(/\s+-\s+/, $record, 2);

		# Check whether colors are enabled:
		unless ($coloured) {
			# Display plain record header:
			print "Date: $date\n\n";
		}
		else {
			# Display colored record header:
			print colored ("Date: $date", 'yellow');
			print "\n\n";
		}

		# Display the record body:
		print wrap('    ', '    ', $message);
		print "\n";
	}
	else {
		# Display the short record:
		print $record;
	}

	# Return success:
	return 1;
}

# Display log entries:
sub display_log {
	# Initialize required variables:
	my @lines = ();
	my $count = 0;

	# Prepare the file name:
	my $file  = catfile($blogdir, $weblog, 'log');

	# Open the log file for reading:
	open(LOG, "$file") or return 0;

	# Process each entŕy:
	while (my $record = <LOG>) {
		# Check whether to use reverse order:
		if ($reverse) {
			# Display the log entry immediately:
			display_record($record);

			# Check whether the limited number of displayed entries is requested:
			if ($number > 0) {
				# Increase the displayed entries counter:
				$count++;

				# End loop when the counter reaches the limit:
				last if $count == $number;
			}
		}
		else {
			# Prepend the log entry to the list of records to be displayed later:
			unshift(@lines, $record);
		}
	}

	# Close the file:
	close(LOG);

	# Unless the reverse order was requested, and therefore records have been
	# already displayed, display them now:
	unless ($reverse) {
		# Process each log entry:
		foreach my $record (@lines) {
			# Display the log entry:
			display_record($record);

			# Check whether the limited number of displayed entries is requested:
			if ($number > 0) {
				# Increase the displayed entries counter:
				$count++;

				# End loop when the counter reaches the limit:
				last if $count == $number;
			}
		}
	}

	# Return success:
	return 1;
}

# Display log statistics:
sub display_statistics {
	# Initialize required variables:
	my $count = 0;
	my $first = '';
	my $last  = '';

	# Prepare the file name:
	my $file  = catfile($blogdir, $weblog, 'log');

	# Open the log file for reading:
	open(LOG, "$file") or return 0;

	# Process each entry:
	while (my $record = <LOG>) {
		# Check whether the entry is the first and store its timestamp:
		($first = $record) =~ s/ - .*\n// unless $first;

		# Store the time stamp of the current entry:
		($last  = $record) =~ s/ - .*\n//;

		# Count the entry:
		$count++;
	}

	# Close the file:
	close(LOG);

	# Check whether to use compact listing:
	unless ($compact) {
		# Display full results:
		print "Log entries: $count\n";
		print "First entry: $first\n";
		print "Last entry:  $last\n";
	} else {
		# Display shortened results:
		printf("There is a total number of $count log %s.\n",
		(($count != 0) ? 'entries' : 'entry'));
	}

	# Return success:
	return 1;
}

# Initialize command line options:
my $type = 'log';

# Set up the option parser:
Getopt::Long::Configure('no_auto_abbrev', 'no_ignore_case', 'bundling');

# Process command line options:
GetOptions(
	'help|h'               => sub { display_help();    exit 0; },
	'version|v'            => sub { display_version(); exit 0; },
	'reverse|r'            => sub { $reverse  = 1;       },
	'short|s'              => sub { $compact  = 1;       },
	'stat|stats|S'         => sub { $type     = 'stats'; },
	'no-color|no-colour|C' => sub { $coloured = 0;       },
	'color|colour|c'       => sub { $coloured = 1;       },
	'quiet|q'              => sub { $verbose  = 0;       },
	'verbose|V'            => sub { $verbose  = 1;       },
	'blogdir|b=s'          => sub { $blogdir  = $_[1];   },
	'number|n=i'           => sub { $number   = $_[1];   },
);

# Detect superfluous options:
exit_with_error("Invalid option `$ARGV[0]'.", 22) if (scalar(@ARGV) != 0);

# Check whether the repository is present, no matter how naive this method
# actually is:
exit_with_error("Not a We-Blog repository! Try `we-blog-init' first.",1)
	unless (-d catdir($blogdir, ));

# Unless specified on the command line, read the color setup from the
# configuration file:
unless (defined $coloured) {
	# Read the configuration file:
	my $conf  = read_conf();

	# Read required data from the configuration:
	my $temp  = $conf->{color}->{log} || 'false';

	# Set up the output mode:
	$coloured = ($temp =~ /^(true|auto)\s*$/i) ? 1 : 0;
}

# Check whether to list log entries or display statistics:
unless ($type eq 'stats') {
	# Display log records:
	display_log()
		or exit_with_error("Cannot read the log file.", 13);
} else {
	# Display log statistics:
	display_statistics()
		or exit_with_error("Cannot read the log file.", 13);
}

# Return success:
exit 0;

__END__

=head1 NAME

we-blog-log - displays the We-Blog repository log

=head1 SYNOPSIS

B<we-blog-log> [B<-cqrsCV>] [B<-b> I<directory>] [B<-n> I<number>]

B<we-blog-log> B<-h>|B<-v>

=head1 DESCRIPTION

B<we-blog-log> displays the content of the We-Blog repository log.

=head1 OPTIONS

=over

=item B<-b> I<directory>, B<--blogdir> I<directory>

Allows you to specify a I<directory> in which the We-Blog repository
is placed. The default option is a current working directory.

=item B<-n> I<number>, B<--number> I<number>

Allows you to specify a I<number> of log entries to be listed.

=item B<-s>, B<--short>

Tells B<we-blog-log> to display each log entry on a single line.

=item B<-r>, B<--reverse>

Tells B<we-blog-log> to display log entries in reverse order.

=item B<-c>, B<--color>

Enables colored output. When supplied, this option overrides the relevant
configuration option.

=item B<-C>, B<--no-color>

Disables colored output. When supplied, this option overrides the relevant
configuration option.

=item B<-q>, B<--quiet>

Disables displaying of unnecessary messages.

=item B<-V>, B<--verbose>

Enables displaying of all messages. This is the default option.

=item B<-h>, B<--help>

Displays usage information and exits.

=item B<-v>, B<--version>

Displays version information and exits.

=back

=head1 FILES

=over

=item I<.we-blog/log>

A file containing the repository log.

=back

=head1 EXAMPLE USAGE

List the whole repository history:

	$ we-blog-log
	Date: Sun Jul 25 16:48:22 2010

			Edited the page with ID 5.

	Date: Tue Jul  6 18:54:59 2010

			Edited the page with ID 5.

	etc.

List the whole repository history in reverse order:

	$ we-blog-log -r
	Date: Tue Feb 10 00:40:16 2009

			Created/recovered a We-Blog repository.

	Date: Tue Feb 10 01:06:44 2009

			Added the page with ID 1.

	etc.

Display the very first log entry on a single line:

	$ we-blog-log -rs -n 1
	Tue Feb 10 00:40:16 2009 - Created/recovered a We-Blog repository.

=head1 SEE ALSO

B<we-blog-init>(1), B<we-blog-config>(1)

=head1 BUGS

To report a bug or to send a patch, please, add a new issue to the bug
tracker at <http://code.google.com/p/we-blog/issues/>, or visit the
discussion group at <https://groups.google.com/d/forum/tonk-we-blog>.

=head1 COPYRIGHT

Copyright (c) 2008-2011 Jaromir Hradilek / 2011-2012 Ton Kersten

This program is free software; see the source for copying conditions. It is
distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.

=cut
