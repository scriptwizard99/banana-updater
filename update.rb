=begin
    Banana Auto Updater

    Copyright (C) 2014  Joseph V. Gibbs III

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

    You can contact the author at scriptwizard99@gmail.com
=end


require 'nokogiri'
require 'logger'
require_relative 'lib/config.rb'
require_relative 'lib/downloader.rb'

#----------------------------------- CONSTANTS --------------------------
UPDATER_VERSION='0.1.0'
UPDATER_NAME='Banana Updater'
#DEFAULT_BASE_URL='http://fallofromegame.com/alamazeorders/downloads'
DEFAULT_BASE_URL='https://bintray.com/artifact/download/scriptwizard/generic'
CONFIG_NAME='BananaUpdaterConfig.xml'

UPDATER_BINARY=ENV['OCRA_EXECUTABLE']
GUI_FILE="parserGUI.exe"
LOG_FILE="updaterLog.txt"
SUPPORT_EMAIL="support@alamaze.com and scriptwizard99@gmail.com"
#------------------------------------------------------------------------

#-----------------------------------  GLOBALS  --------------------------
$LOG=nil
$configInfo=nil
$downloader=nil
#------------------------------------------------------------------------

def echoLog(msg)
   printf("%s\n", msg)
   $LOG.info(msg)
end

# If we do not have a config file here, fetch one.
def getConfigFile
   $LOG.debug("Checking to see if #{CONFIG_NAME} exists.")
   if File.exist?(CONFIG_NAME)
      $LOG.debug("Config file exists. No need to fetch from afar.")
   else
      $LOG.info("Config file %s") # TODD stopped coding here
      downloadConfigFile()
   end
   return CONFIG_NAME
end

def downloadConfigFile
   url="#{DEFAULT_BASE_URL}/#{CONFIG_NAME}"
   rc = $downloader.downloadFile(url, 500, CONFIG_NAME)
   return rc
end

def runTarget(target)
   echoLog("Running #{target.getName}")
   cwd=Dir.pwd
   pid = Process.spawn("#{cwd}/#{target.getFile}")
   Process.detach(pid)
end

#<<<<<<<<<<<<<<<<<<<<<<<<<<<< START >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

$LOG=Logger.new(LOG_FILE)
$LOG.info("====================== S T A R T ======================")
$downloader=Downloader.new

begin

   cname=getConfigFile
   cfg=ConfigInfo.new(cname)
   cfg.getListOfTargets.each do |target|
      printf("-------------------------------------------------------\n")
      printf("Target : %s\n", target.getName)
      ok=$downloader.fetch(DEFAULT_BASE_URL,target)
#     printf("Result : %s\n", ok)
      if ok and target.isRunable == 'true'
         runTarget(target)
      end
      
   end



rescue Exception => e
   printf("CAUGHT EXCEPTION! CHECK LOG FOR DETAILS")
   $LOG.error("Caught exception")
   $LOG.error(e)
end

sleep 10
$LOG.info("====================== E N D ======================")
exit 0


#cfg=ConfigInfo.new("doc/config.xml")
