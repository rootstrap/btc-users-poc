RSpec::Matchers.define :redirect_to do |expected|
  match do |actual|
    return false unless actual.status == 302
    actual.headers['Location'] == expected
  end
end
