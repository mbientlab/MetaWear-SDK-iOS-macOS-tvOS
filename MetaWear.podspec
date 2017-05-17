Pod::Spec.new do |s|
  s.name               = 'MetaWear'
  s.version            = '2.8.4'
  s.license            = { :type => 'Commercial', :text => 'See https://www.mbientlab.com/terms/', :file => 'LICENSE' }
  s.homepage           = 'https://mbientlab.com'
  s.summary            = 'iOS/macOS/tvOS API and documentation for the MetaWear platform'
  s.description        = <<-DESC
                         This library allows for simple interfacing with the MetaWear Bluetooth (BLE)
                         sensor platform.  Stream or log a variety of sensor data via simple API calls.
                         Contact us at hello@mbientlab.com if you need custom hardware or help with App development.
                         See www.mbientlab.com for details.
                         DESC
  s.author             = { 'Stephen Schiffli' => 'stephen@mbientlab.com' }

  s.source             = { :git => 'https://github.com/mbientlab/MetaWear-SDK-iOS-macOS-tvOS.git', :tag => s.version.to_s }

  s.platform = :ios, :osx, :tvos
  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.11'
  s.tvos.deployment_target = '10.0'

  s.social_media_url   = "https://twitter.com/mbientLab"
  s.documentation_url  = "https://www.mbientlab.com/docs/metawear/ios/#{s.version}/index.html"

  s.source_files = 'MetaWear/{Assets,Classes,Internal}/**/*.{h,m}'
  s.private_header_files = 'MetaWear/Internal/**/*.h'

  s.frameworks      = 'CoreData', 'CoreBluetooth'
  s.dependency 'Bolts/Tasks', '~> 1.8.4'
  s.dependency 'FastCoding+tvOS', '~> 3.2.1'
end
