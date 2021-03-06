#!/usr/bin/env perl
# vi: set sw=4 ts=4 ai:
# $Id: we-blog-remove.pl 2 2011-09-21 15:34:50 tonk $

# we-blog-remove - removes a post or page from the We-Blog repository
# Copyright (c) 2011-2012 Ton Kersten
# Copyright (c) 2008-2011 Jaromir Hradilek

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

# Set the library path and use our own module
use lib dirname($0);
use We;

# Command-line options:
my  $type    = 'post';                              # Type: post or page.
my  $removed = '';                                  # List of removed IDs.

# Display usage information:
sub display_help {
	# Display the usage:
	print << "END_HELP";
Usage: $NAME [-fipqPV] [-b DIRECTORY] ID...
			 $NAME -h|-v

	-b, --blogdir directory     specify a directory in which the We-Blog
	                            repository is placed
	-p, --page                  remove a page or pages
	-P, --post                  remove a blog post or blog posts
	-i, --interactive           require manual confirmation of each removal
	-f, --force                 do not require manual confirmation
	-q, --quiet                 do not display unnecessary messages
	-V, --verbose               display all messages
	-h, --help                  display this help and exit
	-v, --version               display version information and exit
END_HELP

	# Return success:
	return 1;
}

# Remove a record or records from the repository:
sub remove_records {
	my $type = shift || 'post';
	my $ids  = shift || die 'Missing argument';

	# Initialize required variables:
	my @list = ();

	# Process each record:
	foreach my $id (@$ids) {
		# Prepare the file names:
		my $head = catfile($blogdir, $weblog, "${type}s", 'head', $id);
		my $body = catfile($blogdir, $weblog, "${type}s", 'body', $id);
		my $raw  = catfile($blogdir, $weblog, "${type}s", 'raw', $id);

		# Enter the interactive mode if requested:
		if ($prompt) {
			# Parse header data:
			my $data = read_ini($head);

			# Check whether the ID exists:
			unless ($data) {
				# Display the appropriate warning:
				display_warning("Unable to read the $type with ID $id.");

				# Move on to the next ID:
				next;
			}

			# Display the prompt:
			print "Remove $type with ID $id titled `" .
						($data->{header}->{title} || '') . "'? ";

			# Skip removal unless confirmed:
			next unless (readline(*STDIN) =~ /^(y|yes)$/i);
		}

		# Try to remove the record header:
		if (unlink $head) {
			# Remove the remaining record data:
			unlink($body, $raw);

			# Add the record to the list of successfully removed IDs:
			push(@list, $id);
		}
		else {
			# Report failure:
			display_warning("Unable to remove the $type with ID $id.");
		}
	}

	# Return the list of removed IDs:
	return @list;
}

# Set up the option parser:
Getopt::Long::Configure('no_auto_abbrev', 'no_ignore_case', 'bundling');

# Process command line options:
GetOptions(
	'help|h'        => sub { display_help();    exit 0; },
	'version|v'     => sub { display_version(); exit 0; },
	'page|pages|p'  => sub { $type    = 'page'; },
	'post|posts|P'  => sub { $type    = 'post'; },
	'force|f'       => sub { $prompt  = 0;      },
	'interactive|i' => sub { $prompt  = 1;      },
	'quiet|q'       => sub { $verbose = 0;      },
	'verbose|V'     => sub { $verbose = 1;      },
	'blogdir|b=s'   => sub { $blogdir = $_[1];  },
);

# Check missing options:
exit_with_error("Wrong number of options.", 22) if (scalar(@ARGV) < 1);

# Check whether the repository is present, no matter how naive this method
# actually is:
exit_with_error("Not a We-Blog repository! Try `we-blog-init' first.",1)
	unless (-d catdir($blogdir, ));

# Remove the records from the repository:
my @list = remove_records($type, \@ARGV);

# End here unless at least one record was actually removed:
unless (@list) {
	# Report abortion:
	print "Aborted.\n" if $verbose;

	# Return failure or success:
	exit (($prompt) ? 0 : 13);
}

# Prepare the list of successfully removed IDs:
$removed =  join(', ', sort(@list));
$removed =~ s/, ([^,]+)$/ and $1/;

# Log the event:
add_to_log("Removed the $type with ID $removed.")
	or display_warning("Unable to log the event.");

# Report success:
print "Successfully removed the $type with ID $removed.\n" if $verbose;

# Return success:
exit 0;

__END__

=head1 NAME

we-blog-remove  - removes a post or page from the We-Blog repository

=head1 SYNOPSIS

B<we-blog-remove> [B<-fipqPV>] [B<-b> I<directory>] I<id>...

B<we-blog-remove> B<-h>|B<-v>

=head1 DESCRIPTION

B<we-blog-remove> removes a blog post or a page with the specified I<id> from
the We-Blog repository.

=head1 OPTIONS

=over

=item B<-b> I<directory>, B<--blogdir> I<directory>

Allows you to specify a I<directory> in which the We-Blog repository
is placed. The default option is a current working directory.

=item B<-p>, B<--page>, B<--pages>

Tells B<we-blog-remove> to remove a page or pages.

=item B<-P>, B<--post>, B<--posts>

Tells B<we-blog-remove> to remove a blog post or blog posts. This is the
default option.

=item B<-f>, B<--force>

Disables requiring manual confirmation of each blog post or page removal.
This is the default option.

=item B<-i>, B<--interactive>

Enables requiring manual confirmation of each blog post or page removal.

=item B<-q>, B<--quiet>

Disables displaying of unnecessary messages.

=item B<-V>, B<--verbose>

Enables displaying of all messages. This is the default option.

=item B<-h>, B<--help>

Displays usage information and exits.

=item B<-v>, B<--version>

Displays version information and exits.

=back

=head1 EXAMPLE USAGE

Remove a blog post:

	$ we-blog-remove 10
	Successfully removed the post with ID 10.

Remove a page:

	$ we-blog-remove -p 4
	Successfully removed the page with ID 4.

Remove multiple blog posts:

	$ we-blog-remove 10 4 6
	Successfully removed the post with ID 10, 4 and 6.

Remove multiple blog posts safely:

	$ we-blog-remove -i 10 4 6
	Remove the post with ID 10 titled `Debian and Fedora Packages'? y
	Remove the post with ID 4 titled `We-Blog 0.8.0 RC2'? y
	Remove the post with ID 6 titled `We-Blog 0.8.1'? y
	Successfully removed the post with ID 10, 4 and 6.

=head1 SEE ALSO

B<we-blog-config>(1), B<we-blog-add>(1), B<we-blog-list>(1)

=head1 BUGS

To report a bug or to send a patch, please, add a new issue to the bug
tracker at <http://code.google.com/p/we-blog/issues/>, or visit the
discussion group at <http://groups.google.com/group/we-blog/>.

=head1 COPYRIGHT

Copyright (c) 2008-2011 Jaromir Hradilek / 2011-2012 Ton Kersten

This program is free software; see the source for copying conditions. It is
distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.

=cut
