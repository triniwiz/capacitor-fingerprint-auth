
  Pod::Spec.new do |s|
    s.name = 'CapacitorFingerprintAuth'
    s.version = '0.0.2'
    s.summary = 'FingerPrint Auth'
    s.license = 'MIT'
    s.homepage = 'https://github.com/triniwiz/capacitor-fingerprint-auth'
    s.author = 'Osei Fortune'
    s.source = { :git => '', :tag => s.version.to_s }
    s.source_files = 'ios/Plugin/Plugin/*.{swift,h,m,c,cc,mm,cpp}' ,'ios/Plugin/Plugin/**/*.{swift,h,m,c,cc,mm,cpp}','ios/*.{swift,h,m,c,cc,mm,cpp}'
    s.ios.deployment_target  = '11.0'
    s.dependency 'Capacitor'
  end
