@echo off
rem ==========================================================================
rem = This batch file calls ocra to generate a runable binary for the
rem = BananaMap Updater which is written in Ruby. Because ocra
rem = packages an entire ruby installation, the user does no need to have
rem = Ruby installed on their machine. The binary is fully self contained.
rem =
rem = For debug, append --verbose --debug --debug-extract to the end of the command
rem ==========================================================================

echo "Creating updater"
ocra --chdir-first update.rb

del updateBananaMap.exe
echo "Renaming binary to updateBananaMap.exe"
rename update.exe updateBananaMap.exe
