#!/usr/bin/env perl
# vi: set sw=4 ts=4 ai:
# $Id: We.pm 6 2012-07-12 13:06:51 tonk $

# we-blog.pm - Perl Module for We-Blog.
# This module contains all generic things
# Copyright (c) 2011-2012 Ton Kersten

# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the
# Free Software Foundation, version 3 of the License.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTA-
# BILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public
# License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program. If not, see <http://www.gnu.org/licenses/>.

use strict;
use warnings;
use File::Basename;
require Exporter;

use vars qw(
			$NAME
			$VERSION
			$blogdir
			$coloured
			$compact
			$destdir
			$editor
			$force
			$number
			$process
			$prompt
			$reverse
			$verbose
			$weblog
		);

# General script information:
$NAME		= basename($0, '.pl');	# Script name.
$VERSION	= '0.9';				# Script version.

# General script settings:
$blogdir	= '.';					# Repository location.
$coloured	= undef;				# Use colors?
$compact	= 0;					# Use compact listing?
$destdir	= '.';					# HTML pages location.
$editor		= '';					# Editor to use.
$force		= 0;					# Force files rewrite?
$number		= 0;					# Listed records limit.
$process	= 1;					# Use processor?
$prompt		= 0;					# Ask for confirmation?
$reverse	= 0;					# Use reverse order?
$verbose	= 1;					# Verbosity level.
$weblog		= '.we-blog';			# We-blog data and config directory

# Set up the __WARN__ signal handler:
$SIG{__WARN__} = sub {
	print STDERR $NAME . ": " . (shift);
};

# Display an error message, and terminate the script:
sub exit_with_error {
	my $message      = shift || 'An error has occurred.';
	my $return_value = shift || 1;

	# Display the error message:
	print STDERR $NAME . ": $message\n";

	# Terminate the script:
	exit $return_value;
}

# Display a warning message:
sub display_warning {
	my $message = shift || 'A warning was requested.';

	# Display the warning message:
	print STDERR "$message\n";

	# Return success:
	return 1;
}

# Display version information:
sub display_version {

	# Display the version:
	print << "END_VERSION";
$NAME version $VERSION

Copyright (c) 2011-2012 Ton Kersten
Copyright (c) 2008-2011 Jaromir Hradilek

This program is free software; see the source for copying conditions. It is
distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PAR-
TICULAR PURPOSE.

END_VERSION

	# Return success:
	return 1;
}

# Add the event to the log:
sub add_to_log {
	my $text = shift || 'Something miraculous has just happened!';

	# Prepare the log file name:
	my $file = catfile($blogdir, $weblog, 'log');

	# Open the log file for appending:
	open(LOG, ">>$file") or return 0;

	# Write the event to the file:
	print LOG localtime(time) . " - $text\n";

	# Close the file:
	close(LOG);

	# Return success:
	return 1;
}

# Translate given date to YYYY-MM-DD string:
sub date_to_string {
	my @date = localtime(shift);
	return sprintf("%d-%02d-%02d", ($date[5] + 1900), ++$date[4], $date[3]);
}

# Translate a date to a string in the RFC 822 form:
sub rfc_822_date {
	my @date = localtime(shift);

	# Prepare aliases:
	my @months = qw( Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec );
	my @days   = qw( Sun Mon Tue Wed Thu Fri Sat );

	# Return the result:
	return sprintf("%s, %02d %s %d %02d:%02d:%02d GMT",
			$days[$date[6]],
			$date[3], $months[$date[4]], 1900 + $date[5],
			$date[2], $date[1], $date[0]);
}

sub date_time_to_string {
	my @date = localtime(shift);

	# Return the result:
	return sprintf("%02d-%02d-%02d %02d:%02d", ($date[5] + 1900),
		++$date[4], $date[3], $date[2], $date[1], $date[0]);
}

# Read data from the INI file:
sub read_ini {
	my $file    = shift || die 'Missing argument';

	# Initialize required variables:
	my $hash    = {};
	my $section = 'default';

	# Open the file for reading:
	open(INI, "$file") or return 0;

	# Process each line:
	while (my $line = <INI>) {
		# Skip comment lines
		if ($line =~ /^\s*\#/) {
			next;
		}

		# Parse the line:
		if ($line =~ /^\s*\[([^\]]+)\]\s*$/) {
			# Change the section:
			$section = $1;
		}
		elsif ($line =~ /^\s*(\S+)\s*=\s*(\S.*)$/) {
			# Add the option to the hash:
			$hash->{$section}->{$1} = $2;
		}
	}

	# Close the file:
	close(INI);

	# Return the result:
	return $hash;
}

# Write data to the INI file:
sub write_ini {
	my $file = shift || 'Missing argument';
	my $hash = shift || 'Missing argument';

	# Open the file for writing:
	open(INI, ">$file") or return 0;

	# Process each section:
	foreach my $section (sort(keys(%$hash))) {
		# Write the section header to the file:
		print INI "[$section]\n";

		# Process each option in the section:
		foreach my $option (sort(keys(%{$hash->{$section}}))) {
			# Write the option and its value to the file:
			print INI "  $option = $hash->{$section}->{$option}\n";
		}
	}

	# Close the file:
	close(INI);

	# Return success:
	return 1;
}

# Read the content of the configuration file:
sub read_conf {
	# Prepare the file name:
	my $file = catfile($blogdir, $weblog, 'config');

	# Parse the file:
	if (my $conf = read_ini($file)) {
		# Return the result:
		return $conf;
	}
	else {
		# Report failure:
		display_warning("Unable to read the configuration.");

		# Return an empty configuration:
		return {};
	}
}

# Read configuration from the temporary file, and save it:
sub write_conf {
	my $conf = shift || die 'Missing argument';

	# Prepare the file name:
	my $file = catfile($blogdir, $weblog, 'config');

	# Save the configuration file:
	unless (write_ini($file, $conf)) {
		# Report failure:
		display_warning("Unable to write the configuration.");

		# Return failure:
		return 0;
	}

	# Return success:
	return 1;
}

1;
