module Support
  module Helpers
    # TODO: better name for this?
    def will_expect(&block)
      expect { subject }
    end
  end
end
