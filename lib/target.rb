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

require 'logger'

class UpdateTarget
   def initialize(name, file, size, md5, version, runable)
      @name = name
      @file = file
      @size = size
      @md5 = md5
      @version = version
      @runable = runable
   end

   def getName
      return @name
   end

   def getFile
      return @file
   end

   def getSize
      return @size
   end

   def getMD5
      return @md5
   end

   def getVersion
      return @version
   end

   def isRunable
      return @runable
   end

   def to_s
      return sprintf("%s, %s, %s, %s, %s, %s\n",@name,@file,@size,@md5,@version,@runable)
   end
end # class UpdateTarget

