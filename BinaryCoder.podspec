Pod::Spec.new do |s|
  s.name         = 'BinaryCoder'
  s.version      = '0.0.1'
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.summary      = 'Implementation of the flat binary coder conforming to Encoder / Decoder protocols.'
  s.homepage     = 'https://github.com/borzh/BinaryCoder'
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.authors      = { 'Mike Ash' => 'mike@mikeash.com', 'Boris Godin' => 'borzh62@gmail.com' }
  s.source       = { :git => 'https://github.com/borzh/BinaryCoder.git', :tag => '#{s.version}' }
  s.platform     = :ios
  s.platform     = :osx
  s.source_files = '*.{swift}'

  s.swift_version = '4.2'
  s.requires_arc = true
  s.frameworks   = 'Foundation'
end