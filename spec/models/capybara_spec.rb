require 'rails_helper'
require 'capybara'
require 'capybara/poltergeist'
require 'webmock/rspec'

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, {:js_errors => false, :timeout => 1000})
end
Capybara.default_selector = :xpath


RSpec.describe FriendShip, type: :model do
  before do
    stub_request(:any, @base)
  end

  xit do
    puts `siege -v -t 1s #{@base}`
  end

  xit do
    p RestClient.get(@base)
  end

  xit do
    p fetch(@base)
  end
end


def fetch(url)
  session = Capybara::Session.new(:poltergeist)
  session.driver.headers = {'User-Agent' => ''}
  session.visit url
  if session.status_code != 200
    raise CrawlingError.new(
      status_code: session.status_code,
      response_header: session.response_headers,
      responce_body: session.body
    )
  end
  session.html
end