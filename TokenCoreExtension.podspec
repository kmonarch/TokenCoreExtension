Pod::Spec.new do |s|
  s.name          = "TokenCoreExtension"
  s.version       = "1.0.0"
  s.summary       = "Blockchain Library for imToken"

  s.description   = <<-DESC
  Token Core Library powering imToken iOS app.
  DESC

  s.homepage      = "https://github.com/kmonarch/TokenCoreExtension"
  s.license       = "MIT"
  

  s.author        = { "kmonarch" => "zzhongkai@outlook.com" }
  s.platform      = :ios, "8.0"

  s.source        = { :git => "https://github.com/kmonarch/TokenCoreExtension.git", :tag => "#{s.version}" }
  s.source_files  = "Sources/**/*.{h,m,swift}", "Vendor/**/*.{h,m,c}"
  s.swift_version = "4.0"
  s.vendored_frameworks = [
    "Vendor/secp256k1/secp256k1.framework"
  ]
  s.preserve_paths = "Modules"
  s.pod_target_xcconfig = {
    "SWIFT_INCLUDE_PATHS" => "$(SRCROOT)/TokenCore/Modules",
    "OTHER_LDFLAGS" => "-lObjC",
    "SWIFT_OPTIMIZATION_LEVEL" => "-Owholemodule"
  }

  s.dependency "CryptoSwift", "0.9.0"
  s.dependency "BigInt", "3.0.0"
  s.dependency "GRKOpenSSLFramework"
end




