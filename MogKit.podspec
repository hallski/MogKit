# coding: utf-8
#
#  Be sure to run `pod spec lint MogKit.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|
  s.name         = "MogKit"
  s.version      = "0.8"
  s.summary      = "MogKit is a transducer based data transformation toolkit for Objective-C."

  s.description  = <<-DESC
                   A longer description of MogKit in Markdown format.

                   MogKit is a toolkit that provides fully tested and easily composable transformations
                   to collections and any series of values (like signals, channels, etc). The
                   transformations are independant of the underlying values or data structures which
                   makes them highly reusable.

                   MogKit composes transformations instead of chaining them which means collections
                   will only be passed through once.
                   DESC

  s.homepage     = "https://github.com/mhallendal/MogKit"
  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author       = { "Mikael Hallendal" => "hallski@hallski.org" }

  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.8"

  s.source       = { :git => "https://github.com/mhallendal/MogKit.git", :tag => "0.8" }

  s.source_files  = "MogKit/*.{h,m}"
  # s.exclude_files = "MogKitTests/*"

  s.public_header_files = "MogKit/*.h"
  s.requires_arc = true
end
