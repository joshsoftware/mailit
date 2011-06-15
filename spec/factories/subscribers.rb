Factory.define :subscriber do |s|
  s.first_name "test_fn"
  s.last_name "test_ln"
  s.sequence(:email) {|n| "joshsoftwaretest#{n}@gmail.com" }
end
