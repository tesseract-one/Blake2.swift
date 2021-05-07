Pod::Spec.new do |s|
  s.name             = 'Blake2b.swift'
  s.version          = '0.1.0'
  s.summary          = 'Swift wrapper for reference C implementation of Blake2b hash.'

  s.description      = <<-DESC
Swift wrapper for reference C implementation of Blake2b hash. Blake2b only.
                       DESC

  s.homepage         = 'https://github.com/tesseract-one/Blake2b.swift'

  s.license          = { :type => 'Apache 2.0', :file => 'LICENSE' }
  s.author           = { 'Tesseract Systems, Inc.' => 'info@tesseract.one' }
  s.source           = { :git => 'https://github.com/tesseract-one/Blake2b.swift.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'
  s.osx.deployment_target = '10.10'
  s.tvos.deployment_target = '9.0'
  s.watchos.deployment_target = '2.0'
  
  s.swift_versions = ['5', '5.1', '5.2', '5.3']

  s.module_name = 'Blake2b'

  s.source_files = 'Sources/Blake2b/*.swift', 'Sources/CBlake2b/**/*.{h,c}'
  s.public_header_files = 'Sources/CBlake2b/include/*.h'
 
  s.test_spec 'Tests' do |test_spec|
    test_spec.platforms = {:ios => '9.0', :osx => '10.10', :tvos => '9.0'}
    test_spec.source_files = 'Tests/Blake2bTests/**/*.swift'
  end
end
