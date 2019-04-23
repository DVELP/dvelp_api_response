# DvelpApiResponse

A gem to provide standardised responses for api-based applications

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'dvelp_api_response'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install dvelp_api_response

## Usage

### Create concern

`controllers/concerns/version_controller.rb`

```ruby
# frozen_string_literal: true

module VersionController
  VERSION = 1

  extend ActiveSupport::Concern

  def versioned_response(resource, options = {})
    DvelpApiResponse::Distributor.new(
      resource,
      VERSION,
      params[:includes],
      options: options
    ).build_response
  end
end
```

### Base Controller

Add this code to the top of the base controller class

```ruby
require_dependency 'dvelp_api_response/handle_request'
serialization_scope :view_context

include DvelpApiResponse::HandleRequest
include ::VersionController

around_action :process_api_request
```

### Create responder

`responders/resource.rb`

```ruby
# frozen_string_literal: true

class ResourceResponder < DvelpApiResponse::Base
  def versioned_hash
    {
      v_1: %i[
        id
        name
      ]
    }
  end
end
```

### In controller

```ruby
module Api
  class ResourcesController < ::Api::BaseController
    def show
      resource = Resource.find(params[:id])

      response = versioned_response(resource)
      build_response(response, :ok)
    end
  end
end
```

### Specs

#### Create shared_context

`spec/support/shared_contexts/api_response.rb`

```ruby
# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples 'an api response' do
  let(:model) { described_class }

  it 'derives from DvelpApiResponse::Base' do
    expect(model.superclass.name).to eq('DvelpApiResponse::Base')
  end

  describe '#versioned_hash' do
    it 'returns a hash' do
      expect(subject.versioned_hash).to be_a(Hash)
    end

    context ':v_1' do
      it 'has v_1 key' do
        expect(subject.versioned_hash).to have_key(:v_1)
      end

      it 'returns an array of symbols' do
        expect(subject.versioned_hash[:v_1]).to be_a(Array)
      end

      it 'contains relevant keys' do
        v_1_attributes.each do |sym|
          expect(subject.versioned_hash[:v_1]).to include(sym)
        end
      end
    end
  end
end
```

#### Create responder spec

`spec/responders/resource_spec.rb`

```ruby
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ResourceResponder do
  let(:resource) { build(:resource) }
  let(:version) { 1 }
  let(:v_1_attributes) do
    %i[
      id
      name
    ]
  end

  subject { ResourceResponder.new(resource, version) }

  it_behaves_like 'an api response'
end
```

You will need to set an env variable to encrypt requests:

ENV['DVELP_API_AUTH_SECRET_KEY'] = 'Some key'

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/dvelp_api_response. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
