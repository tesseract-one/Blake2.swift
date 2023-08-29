Pod::Spec.new do |s|
  s.name             = 'Blake2'
  s.version          = '999.99.9'
  s.summary          = 'Swift wrapper for reference C implementation of Blake2 hashes.'

  s.description      = <<-DESC
Swift wrapper for reference C implementation of Blake2 hashes.
                       DESC

  s.homepage         = 'https://github.com/tesseract-one/Blake2.swift'

  s.license          = { :type => 'Apache 2.0', :file => 'LICENSE' }
  s.author           = { 'Tesseract Systems, Inc.' => 'info@tesseract.one' }
  s.source           = { :git => 'https://github.com/tesseract-one/Blake2.swift.git', :tag => s.version.to_s }

  s.swift_version    = '5.4'

  base_platforms     = { :ios => '11.0', :osx => '10.13', :tvos => '11.0' }
  s.platforms        = base_platforms.merge({ :watchos => '6.0' })

  s.module_name      = 'Blake2'

  s.source_files = 'Sources/Blake2/*.swift', 'Sources/CBlake2/**/*.{h,c}'
  s.public_header_files = 'Sources/CBlake2/include/*.h'
 
  s.test_spec 'Tests' do |ts|
    ts.platforms = base_platforms
    ts.source_files = 'Tests/Blake2Tests/**/*.swift'
    ts.resource = 'Tests/SubstrateTests/blake2-kat.json'
  end
end
