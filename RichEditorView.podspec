Pod::Spec.new do |s|
  s.name             = "RichEditorView"
  s.version          = "4.0.4"
  s.summary          = "Rich Text Editor for iOS written in Swift -- Base on RichEditorView"
  s.homepage         = "https://github.com/rioksusanto/RichEditorView"
  s.license          = 'BSD 3-clause'
  s.author           = { "Caesar Wirth" => "cjwirth@gmail.com" }
  s.source           = { :git => "https://github.com/rioksusanto/RichEditorView.git", :branch => "develop" } 

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'RichEditorView/Classes/*'
  s.resources = [
      'RichEditorView/Assets/icons/*',
      'RichEditorView/Assets/editor/*'
    ]

  s.dependency 'IGColorPicker', '0.2.1'
  s.dependency 'SCLAlertView', '0.7.0'
end
