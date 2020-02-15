
Pod::Spec.new do |spec|

  spec.name         = "SwiftRequest"
  spec.version      = "1.0.0"
  spec.summary      = "A short summary of SwiftRequest."
  spec.description  = "A short description of SwiftRequest."

  spec.homepage     = "https://github.com/sabarics/SwiftRequest.git"
  # spec.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"


  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Licensing your code is important. See https://choosealicense.com for more info.
  #  CocoaPods will detect a license file if there is a named LICENSE*
  #  Popular ones are 'MIT', 'BSD' and 'Apache License, Version 2.0'.
  #

  spec.license      = "MIT"
  # spec.license      = { :type => "MIT", :file => "FILE_LICENSE" }


  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Specify the authors of the library, with email addresses. Email addresses
  #  of the authors are extracted from the SCM log. E.g. $ git log. CocoaPods also
  #  accepts just a name if you'd rather not provide an email address.
  #
  #  Specify a social_media_url where others can refer to, for example a twitter
  #  profile URL.
  #

  spec.author             = { "sabarics" => "sabarics10@gmail.com" }
  # Or just: spec.author    = "sabarics"
  # spec.authors            = { "sabarics" => "sabarics10@gmail.com" }
  # spec.social_media_url   = "https://twitter.com/sabarics"
  spec.source       = { :git => "https://github.com/sabarics/SwiftRequest.git", :tag => "#{spec.version}" }
  spec.source_files = "SwiftRequest/**/*.{h,m,swift}"
  spec.exclude_files = "Classes/Exclude"
  spec.swift_version = "5"
  spec.platform     = :ios, "11.0"


end
