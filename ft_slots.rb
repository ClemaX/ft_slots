#!/usr/bin/env ruby

require "sinatra"
require "thin"

require "./slots_client"

CALLBACK_PROTO="http"
CALLBACK_HOST="localhost"
CALLBACK_PORT=42069
CALLBACK_PATH="/callback"

HOME_PATH="/"
AUTH_PATH="/authenticate"

CALLBACK_URI="#{CALLBACK_PROTO}://#{CALLBACK_HOST}:#{CALLBACK_PORT}#{CALLBACK_PATH}"

class SlotsApp < Sinatra::Base
	class MissingArgument < StandardError
	end

	class AuthenticationFailure < StandardError
	
	end
	def initialize()
		@slots_client = SlotsClient.new("#{__dir__}/config.yml", CALLBACK_URI)
	end

	configure do
		set :server, :thin
		set :environment, :production
		set :bind, CALLBACK_HOST
		set :port, CALLBACK_PORT
	end

	get HOME_PATH do
		redirect "/authenticate"
	end

	get CALLBACK_PATH do
		# Get code
		code = params[:code]
		raise MissingArgument unless code
	
		# Complete authentication
		raise AuthenticationFailure unless @slots_client.auth_code_callback(code)

		"TODO: redirect"
	end
	
	get AUTH_PATH do
		redirect @slots_client.authenticate()
	end

	error MissingArgument do
		status 400
		"Missing argument!"
	end

	error AuthenticationFailure do
		status 500
		"Authentication failure!"
	end
end

SlotsApp.start!

