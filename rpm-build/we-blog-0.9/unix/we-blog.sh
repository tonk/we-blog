#!/bin/sh
# vi: set sw=4 ts=4 ai:
# $Id: we-blog.sh 3 2012-07-09 12:55:25 tonk $

# we-blog, a command wrapper for We-Blog
# Copyright (c) 2011-2013 Ton Kersten
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

# General script information:
NAME=${0##*/}
VERSION='0.9'

# Get the command if any, and shift command line options:
COMMAND=$1
shift

# Substitute aliases:
case "$COMMAND" in
	"ed")         COMMAND="edit";;
	"in")         COMMAND="init";;
	"ls")         COMMAND="list";;
	"mk")         COMMAND="make";;
	"rm" | "del") COMMAND="remove";;
	"cf" | "cfg") COMMAND="config";;
	"vs" | "ver") COMMAND="version";;
esac

# Parse the command and perform an appropriate action:
case "$COMMAND" in
	"add" | "log" | "edit" | "init" | "list" | "make" | "config" | "remove")
		# Run the selected utility:
		exec we-blog-$COMMAND "$@"
	;;
	"-h" | "--help" | "help")
		# Get the command, if any:
		COMMAND=$1

		# Parse the command, and display its usage:
		case "$COMMAND" in
			"add" | "log" | "edit" | "init" | "list" | "make" | "config" | "remove")
				# Display the utility usage information:
				exec we-blog-$COMMAND --help
			;;

			*)
				# Display the list of available commands:
				echo "Usage: $NAME COMMAND [OPTION...]"
				echo
				echo "Basic commands:"
				echo "  init     create or recover a We-Blog repository"
				echo "  config   display or set We-Blog configuration options"
				echo "  add      add a blog post or page to a We-Blog repository"
				echo "  edit     edit a blog post or page in a We-Blog repository"
				echo "  remove   remove a blog post or page from a We-Blog repository"
				echo "  list     list blog posts or pages in a We-Blog repository"
				echo "  make     generate a blog from a We-Blog repository"
				echo "  log      display a We-Blog repository log"
				echo
				echo "Additional commands:"
				echo "  help [COMMAND]  display usage information on the selected command"
				echo "  man [COMMAND]   display a manual page for the selected command"
				echo "  version         display version information"
				echo
				echo "Command aliases:"
				echo "  in       init"
				echo "  ed       edit"
				echo "  ls       list"
				echo "  mk       make"
				echo "  cf, cfg  config"
				echo "  rm, del  remove"
				echo "  vs, ver  version"

				# Return success:
				exit 0
			;;
		esac
	;;
	"man")
		# Get the command, if any:
		COMMAND=$1

		# Parse the command, and display its manual page:
		case "$COMMAND" in
			"add" | "log" | "edit" | "init" | "list" | "make" | "config" | "remove")
				# Display the utility usage information:
				exec man we-blog-$COMMAND
			;;
			*)
				# Display a general manual page:
				exec man we-blog
			;;
		esac
	;;
	"-v" | "--version" | "version")
		# Display version information:
		cat <<- @EOF
			We-Blog $VERSION

			Copyright (c) 2011-2013 Ton Kersten
			Copyright (c) 2009-2011 Jaromir Hradilek

			This program is free software; see the source for copying conditions. It is
			distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
			without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PAR-
			TICULAR PURPOSE.
		@EOF

		# Return success:
		exit 0
	;;
	*)
		# Respond to a wrong or missing command:
		echo "Usage: $NAME COMMAND [OPTION...]" >&2
		echo "Try \`$NAME help' for more information." >&2

		# Return failure:
		exit 22
	;;
esac
