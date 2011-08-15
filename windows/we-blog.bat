@echo off

REM we-blog, a command wrapper for We-Blog
REM Copyright (C) 2009-2011 Sergey Kuznetsov
REM
REM This program is  free software:  you can redistribute it and/or modify it
REM under  the terms  of the  GNU General Public License  as published by the
REM Free Software Foundation, version 3 of the License.
REM
REM This program  is  distributed  in the hope  that it will  be useful,  but
REM WITHOUT  ANY WARRANTY;  without  even the implied  warranty of MERCHANTA-
REM BILITY  or  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public
REM License for more details.
REM
REM You should have received a copy of the  GNU General Public License  along
REM with this program. If not, see <http://www.gnu.org/licenses/>.

set we-blogNAME=%~n0
set we-blogVERSION=0.5

if defined we-blogCOMMAND (
	perl %~d0%~p0..\src\%we-blogCOMMAND%.pl %*
	goto :EOF
)

if exist we-blog-%1.bat (
	call we-blog-%1.bat %2 %3 %4 %5 %6 %7 %8 %9
	goto :EOF
)

if /i "%1"=="help" (
	if exist we-blog-%2.bat (
		call we-blog-%2.bat -h
		goto :EOF
	)
)

echo Usage: %we-blogNAME% COMMAND [OPTION...]
echo.
echo Available commands:
echo   init    create or recover a We-Blog repository
echo   config  display or set We-Blog configuration options
echo   add     add a blog post or page to a We-Blog repository
echo   edit    edit a blog post or page in a We-Blog repository
echo   remove  remove a blog post or page from a We-Blog repository
echo   list    list blog posts or pages in a We-Blog repository
echo   make    generate a blog from a We-Blog repository
echo   log     display a We-Blog repository log
echo.
echo Type \`%we-blogNAME% help COMMAND' for command details.
