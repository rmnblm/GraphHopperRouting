Pod::Spec.new do |s|
  s.name = 'GraphHopperRouting'
  s.version = '0.1.0'
  s.license = 'MIT'
  s.homepage = 'https://github.com/rmnblm/GraphHopperRouting.git'
  s.summary = 'The GraphHopper Routing API wrapped in an easy-to-use Swift framework. '
  s.authors = { 'rmnblm' => 'rmnblm@gmail.com' }
  s.source = { :git => 'https://github.com/rmnblm/GraphHopperRouting.git', :tag => s.version }
  s.ios.deployment_target = '8.0'
  s.source_files = 'GraphHopperRouting/*.swift'
end
