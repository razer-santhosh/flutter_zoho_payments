Pod::Spec.new do |s|
  s.name             = 'flutter_zoho_payments'
  s.version          = '0.3.0'
  s.summary          = 'Flutter plugin for Zoho Payments SDK (iOS).'
  s.description      = <<-DESC
Flutter plugin that bridges the native Zoho Payments iOS SDK (ZohoPayments)
into Flutter apps. The native SDK itself is distributed via Swift Package
Manager and must be added to the host app's Runner target separately.
                       DESC
  s.homepage         = 'https://github.com/razer-santhosh/flutter_zoho_payments'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'razer-santhosh' => 'noreply@example.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform         = :ios, '15.0'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version    = '5.0'
end
