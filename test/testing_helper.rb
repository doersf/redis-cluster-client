# frozen_string_literal: true

require 'minitest/autorun'
require 'redis_client'

class RedisClient
  TEST_REDIS_SCHEME = ENV.fetch('REDIS_SCHEME', 'redis')
  TEST_REDIS_SSL = TEST_REDIS_SCHEME == 'rediss'
  TEST_REDIS_HOST = '127.0.0.1'
  TEST_REDIS_PORTS = (6379..6384).freeze
  TEST_NODE_URIS = TEST_REDIS_PORTS.map { |port| "#{TEST_REDIS_SCHEME}://#{TEST_REDIS_HOST}:#{port}" }.freeze
  TEST_NODE_OPTIONS = TEST_REDIS_PORTS.to_h { |port| ["#{TEST_REDIS_HOST}:#{port}", { host: TEST_REDIS_HOST, port: port }] }
                                      .transform_values { |v| TEST_REDIS_SSL ? v.merge(ssl: true) : v }.freeze

  module TestingHelper
    def setup
      @raw_clients = TEST_NODE_URIS.map { |addr| ::RedisClient.config(url: addr).new_client }
    end

    def teardown
      @raw_clients&.each(&:close)
    end
  end
end
