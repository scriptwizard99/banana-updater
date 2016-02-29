#!/usr/bin/ruby
=begin
    This script handles downloading a file from a URL.

    Copyright (C) 2015  Joseph V. Gibbs III

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

require 'net/http'
require 'digest'
require 'logger'
require_relative 'target'

#----------------------------------------------------------------------------

class Downloader


   def initialize
   #   $LOG.info("ConfigInfo initialized. baseURL(%s) numTargets(%s)"% [ @baseURL, @targetList.size ])
   end

   # Must open output file for writing in BINARY mode
   def downloadFile(url,sizeStr,outputFile, limit=10)

      if limit==0
         $LOG.error("Too many redirects")
         return false
      end
   
      size = sizeStr.to_i
      uri = URI(url)
      if limit==10
         printf("-------------------------------------------------------\n")
         echoLog("Downloading %s into %s"% [uri, outputFile])
      else
         $LOG.info("Downloading %s into %s"% [uri, outputFile])
      end
      numBytes=0
      Net::HTTP.start(uri.host, uri.port, 
                      :use_ssl => uri.scheme == 'https',
                      :verify_mode => OpenSSL::SSL::VERIFY_NONE ) do |http|
   
        #http.verify_mode = OpenSSL::SSL::VERIFY_NONE 
        request = Net::HTTP::Get.new uri.request_uri
        http.request request do |response|
   
          # Check reponse to see if there is anything to download
          if  response.is_a?(Net::HTTPRedirection ) 
             location = response['location']
             $LOG.warn("redirected to #{location}")
             success = downloadFile(location, sizeStr, outputFile, limit - 1)
             return success

          elsif  response.is_a?(Net::HTTPSuccess) or response.is_a?(Net::HTTPFound)
             $LOG.info("Good response")
          else
             $LOG.error("Download failed! response(%s)"%response.message)
             printf("Download failed! Response from server: %s\n", response.message)
             return false
          end
   
          # Download body of response into file
          open outputFile, 'wb' do |io|
            response.read_body do |chunk|
              io.write chunk
              numBytes += chunk.size
              percent =  100 * numBytes / size
              printf("Percent Complete : %6.2f\r", percent)
            end # do chunk
          end # do io
        end # do response
      end # do http
   
      $LOG.info("Download complete. Size=%d bytes"% numBytes)
      printf("Percent Complete : %6.2f\r", 100.00)
      printf("\ndone.\nSize=%d bytes\n",numBytes)
      return true
   end

   def getMD5Sum(targetFile)
      return 0 if not File.exist?(targetFile)
      data1=IO.binread(targetFile)
      md5 = Digest::MD5.hexdigest(data1)
      $LOG.info("file(%s) md5sum(%s)"% [targetFile,md5])
      return md5
   end
   
   def checkMD5Sum(targetFile,targetSum, quiet=false)
      matches=false
      $LOG.debug("Checking MD5 for file(%s) target(%s)" % [targetFile,targetSum]) unless quiet
      actualSum=getMD5Sum(targetFile)
      if actualSum == targetSum
         echoLog("Verified MD5 for file(%s) target(%s) == actualSum(%s)" % [targetFile,targetSum,actualSum]) unless quiet
         matches=true
      else
         matches=false
         echoLog("ERROR: Invalid MD5 for file(%s) target(%s) != actualSum(%s)" % [targetFile,targetSum,actualSum]) unless quiet
      end
      return matches
   end

   def fetch(base,target)

      targetFN="#{$binaryDir}/#{target.getFile}"
    
      # First check to see if the file is already here and  
      # if the checksum matches. If so, then we are already done.
      ok = checkMD5Sum(targetFN, target.getMD5, true) 
      if ok
         echoLog("#{target.getName} is already up to date.")
         return ok
      end

      # File is missing or invalid, so get a new one
      (bname,extension)=target.getFile.split('.')
      url=sprintf("%s/%s-%s.%s", base, bname, target.getVersion,extension)
      $LOG.info("Fetching [#{target.getName}] at [#{url}]")

      ok = downloadFile(url, target.getSize, targetFN)
      ok = checkMD5Sum(targetFN, target.getMD5) if ok
      if ok
         echoLog("#{target.getName} downloaded and MD5 sum matches")
      else
         $LOG.error("Problem fetching or verifying #{target.getName}")
      end
      return ok
   end


end # class Downloader
