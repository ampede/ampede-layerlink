require 'rubygems'
require_gem 'rake'

require 'ruby_sources.rb'
require 'objc_sources.rb'

puts ENV['TM_PROJECT_DIRECTORY']

XCODE_PROJECTNAME = 'LayerLinkPlugin'

XCODE_OBJROOT_BUILD = "#{ENV['TM_PROJECT_DIRECTORY']}/Build/"
XCODE_SYMROOT_BUILD = XCODE_OBJROOT_BUILD

XCODE_OBJROOT_INSTALL = "#{ENV['TM_PROJECT_DIRECTORY']}/Install/"
XCODE_DSTROOT_INSTALL_PATH = XCODE_OBJROOT_INSTALL # '/Library/Application Support/SIMBL/Plugins/'
XCODE_GCC_PREFIX_HEADER_INSTALL = 'LayerLinkPlugin_Install_Prefix.pch'

XCODE_SOURCES = RUBY_SOURCES.keys + OBJC_SOURCES.keys + ["#{XCODE_PROJECTNAME}.xcode"]

#######################################################################################

task :default => [ :build ]


directory XCODE_OBJROOT_BUILD
directory XCODE_SYMROOT_BUILD

task :build => XCODE_SOURCES do
  sh "xcodebuild OBJROOT=\"#{XCODE_OBJROOT_BUILD}\" SYMROOT=\"#{XCODE_SYMROOT_BUILD}\""
end

task :clean do
  sh "xcodebuild clean OBJROOT=\"#{XCODE_OBJROOT_BUILD}\" SYMROOT=\"#{XCODE_SYMROOT_BUILD}\""
end


directory XCODE_OBJROOT_INSTALL
directory XCODE_DSTROOT_INSTALL_PATH

task :install => XCODE_SOURCES do
  sh "xcodebuild clean install OBJROOT=\"#{XCODE_OBJROOT_INSTALL}\" DSTROOT=/ INSTALL_PATH=\"#{XCODE_DSTROOT_INSTALL_PATH}\" DEPLOYMENT_LOCATION=YES GCC_PREFIX_HEADER=\"#{XCODE_GCC_PREFIX_HEADER_INSTALL}\""
end

#######################################################################################

rule '.plist' => ['.plist.rb'] do |t|
  rm_r t.name rescue nil
  sh "ruby #{t.source} >> #{t.name}"
end

rule '.strings' => ['.strings.rb'] do |t|
  rm_r t.name rescue nil
  sh "ruby #{t.source} | iconv -f UTF-8 -t UTF-16 >> #{t.name}"
end

