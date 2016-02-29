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
UPDATER_BASE_URL='https://bintray.com/artifact/download/scriptwizard/generic/updater'
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
$baseURL=nil
#------------------------------------------------------------------------

def echoLog(msg)
   printf("%s\n", msg)
   $LOG.info(msg)
end

# If we do not have a config file here, fetch one.
def getConfigFile
#  $LOG.debug("Checking to see if #{CONFIG_NAME} exists.")
#  if File.exist?(CONFIG_NAME)
#     $LOG.debug("Config file exists. No need to fetch from afar.")
#  else
      echoLog("Fetching config file #{CONFIG_NAME}") # TODD stopped coding here
      downloadConfigFile()
#  end
   return CONFIG_NAME
end

def downloadConfigFile
   url="#{UPDATER_BASE_URL}/#{CONFIG_NAME}"

   if defined?(Ocra)
     cfgName="junk.txt"
   else
     cfgName=CONFIG_NAME
   end

   rc = $downloader.downloadFile(url, 1000, cfgName)
   return rc
end

def verifyUpdater(config)
   updater=config.getSelfTarget
   upToDate = $downloader.checkMD5Sum("#{$binaryDir}/#{updater.getFile}", updater.getMD5, true)
   unless upToDate
      ok=$downloader.fetch(UPDATER_BASE_URL,updater)
      if ok
         echoLog("Updater self-updated. Please rerun.")
#        runTarget(updater)
         return false
      else
         echoLog("Self update failed. See TBD for help")                                        #TODO
         exit 1
      end
   end
   $LOG.info("No need to rerun updater. Continuing normally.")
   return true
end

def runTarget(target)
   echoLog("Running #{target.getName}")
   #cwd=Dir.pwd
   targetFN="#{$binaryDir}/#{target.getFile}"
   $LOG.info("Full name [#{targetFN}]")
   pid = Process.spawn(targetFN)
   Process.detach(pid)
end

def downloadTargets(cfg)
   cfg.getListOfTargets.each do |target|
      printf("-------------------------------------------------------\n")
      printf("Target : %s\n", target.getName)
      ok=$downloader.fetch($baseURL,target)
      if ok and target.isRunable == 'true'
         runTarget(target)
      end
   end
end

#<<<<<<<<<<<<<<<<<<<<<<<<<<<< START >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

puts "Updater Binary [#{UPDATER_BINARY}]"
$binaryDir= '.'
$binaryDir=File.dirname(UPDATER_BINARY) unless UPDATER_BINARY.nil?


$LOG=Logger.new("#{$binaryDir}/#{LOG_FILE}")
$LOG.info("====================== S T A R T ======================")

$downloader=Downloader.new

begin

   cname=getConfigFile
   if not defined?(Ocra)
      cfg=ConfigInfo.new(cname)
      $baseURL=cfg.getBaseURL
      ok = verifyUpdater(cfg)
      downloadTargets(cfg) if ok
   else
      printf("Detected that OCRA is running. Skipping remaining processing.\n")
      $downloader.getMD5Sum("update.rb")
      pid = Process.spawn('dir.exe')
      Process.detach(pid)
   end



rescue Exception => e
   printf("CAUGHT EXCEPTION! CHECK LOG FOR DETAILS")
   $LOG.error("Caught exception")
   $LOG.error(e)
end

if not defined?(Ocra)
   sleep 30
end
$LOG.info("====================== E N D ======================")
exit 0


#cfg=ConfigInfo.new("doc/config.xml")
