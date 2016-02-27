#!/usr/bin/ruby
=begin
    Simple Updater - This module contains classes that 
    handle the information from a config file.

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

require 'nokogiri'
require 'logger'
require_relative 'target'


class ConfigInfo


   def initialize(fileName)
      @fileName=fileName
      @targetList=Array.new
      @baseURL=nil
      @selfTarget=nil
      @doc=nil
      
      readFile
      @selfTarget = getTarget(@doc.at_xpath("//updater"))
  
      getTargets

      $LOG.info("ConfigInfo initialized. baseURL(%s) numTargets(%s)"% [ @baseURL, @targetList.size ])

   end

   def readFile
      @doc = Nokogiri::XML(File.open(@fileName)) do |config|
        config.strict.nonet
      end

      @baseURL = @doc.at_xpath("//baseurl").text
   end

   def getTarget(node)
      name = node.at_xpath("name").text
      file = node.at_xpath("file").text
      size = node.at_xpath("size").text
      md5 = node.at_xpath("md5").text
      version = node.at_xpath("version").text
      runable = node.at_xpath("runable").text
      return UpdateTarget.new(name, file, size, md5, version, runable)
   end

   # to be called internally
   def getTargets
      @doc.xpath("//target").each do |node|
         @targetList.push getTarget(node)
      end
   end

   # part of api
   def getListOfTargets
      return @targetList
   end
   

end # class ConfigInfo
