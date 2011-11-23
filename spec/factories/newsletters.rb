Factory.define :newsletter do |n|
  n.mailer_subject "test_subject"
  n.template { fixture_file_upload 'spec/test.html',''}
  n.type_of_mailer "test"
end
