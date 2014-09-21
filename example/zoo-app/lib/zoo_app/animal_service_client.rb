require 'httparty'
require 'zoo_app/models/alligator'

module ZooApp

  class AnimalServiceError < StandardError; end

  class AnimalServiceClient

    include HTTParty
    base_uri 'animal-service.com'

    def self.find_alligators
      response = get("/alligators", :headers => {'Accept' => 'application/json'})
      handle_response response do
        parse_body(response).collect do | hash |
          ZooApp::Animals::Alligator.new(hash)
        end
      end
    end

    def self.find_alligator_by_name name
      response = get("/alligators/#{name}", :headers => {'Accept' => 'application/json'})
      when_successful(response) do
        ZooApp::Animals::Alligator.new(parse_body(response))
      end
    end

    def self.when_successful response
      if response.success?
        yield
      elsif response.code == 404
        nil
      else
        raise AnimalServiceError.new(response.body)
      end
    end

    def self.parse_body response
      JSON.parse(response.body, {:symbolize_names => true})
    end
  end
end