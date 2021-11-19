Pod::Spec.new do |s|
  s.name               = 'MetaWear'
  s.version            = '4.1.3'
  s.license            = { :type => 'Commercial', :text => 'See https://www.mbientlab.com/terms/', :file => 'LICENSE.md' }
  s.homepage           = 'https://mbientlab.com'
  s.summary            = 'iOS/macOS/tvOS/watchOS API and documentation for the MetaWear platform'
  s.description        = <<-DESC
                         This library allows for simple interfacing with the MetaWear Bluetooth (BLE)
                         sensor platform.  Stream or log a variety of sensor data via simple API calls.
                         Contact us at hello@mbientlab.com if you need custom hardware or help with App development.
                         See www.mbientlab.com for details.
                         DESC
  s.author             = { 'Laura Kassovic' => 'laura@mbientlab.com' }

  s.source             = { :git => 'https://github.com/mbientlab/MetaWear-SDK-iOS-macOS-tvOS.git',
                           :tag => s.version.to_s, :submodules => true }

  s.platform = :ios, :osx, :tvos, :watchos
  s.ios.deployment_target = '14.0'
  s.osx.deployment_target = '11.0'
  s.tvos.deployment_target = '14.0'
  s.watchos.deployment_target = '7.0'

  s.swift_version = '5.0'

  s.social_media_url   = "https://twitter.com/mbientLab"
  s.documentation_url  = "https://mbientlab.com/tutorials/"

  s.default_subspec = 'Core'

  s.subspec 'Core' do |s|
    s.preserve_paths = 'MetaWear/MetaWear-SDK-Cpp/src/**/*'
    s.source_files   = 'MetaWear/Core/**/*',
                       'MetaWear/MetaWear-SDK-Cpp/src/metawear/core/*/*.cpp',
                       'MetaWear/MetaWear-SDK-Cpp/src/metawear/dfu/*/*.cpp',
                       'MetaWear/MetaWear-SDK-Cpp/src/metawear/impl/*/*.cpp',
                       'MetaWear/MetaWear-SDK-Cpp/src/metawear/peripheral/*/*.cpp',
                       'MetaWear/MetaWear-SDK-Cpp/src/metawear/platform/*/*.cpp',
                       'MetaWear/MetaWear-SDK-Cpp/src/metawear/processor/*/*.cpp',
                       'MetaWear/MetaWear-SDK-Cpp/src/metawear/sensor/*/*.cpp',
                       'MetaWear/MetaWear-SDK-Cpp/bindings/swift/**/*'
    s.compiler_flags = '-Wno-documentation', '-Wno-comma'
    s.pod_target_xcconfig = {
      'HEADER_SEARCH_PATHS' => '$(PODS_TARGET_SRCROOT)/MetaWear/MetaWear-SDK-Cpp/src',
      'SWIFT_INCLUDE_PATHS' => '$(PODS_TARGET_SRCROOT)/MetaWear/MetaWear-SDK-Cpp/src'
    }
    s.frameworks = 'CoreBluetooth'
    s.dependency 'Bolts-Swift', '~> 1'
  end

  s.subspec 'AsyncUtils' do |s|
    s.source_files = 'MetaWear/AsyncUtils/**/*'
    s.dependency 'MetaWear/Core'
  end

  s.subspec 'UI' do |s|
    s.source_files = 'MetaWear/UI/**/*'
    s.dependency 'MetaWear/Core'
    s.dependency 'MetaWear/AsyncUtils'
  end

  s.subspec 'DFU' do |s|
      s.ios.deployment_target = '14.0'
      s.osx.deployment_target = '11.0'

      s.source_files = 'MetaWear/DFU/**/*'
      s.dependency 'MetaWear/Core'
      s.dependency 'iOSDFULibrary'
  end
end
