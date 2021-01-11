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
		def initialize(message="Missing argument!")
			super(message)
		end
	end

	class AuthenticationFailure < StandardError
		def initialize(message="Authentication failure!")
			super(message)
		end
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
		if !slots_client.authenticated
			redirect "/authenticate"
		else
			"Home"
		end
	end

	get CALLBACK_PATH do
		# Get code
		code = params[:code]
		raise MissingArgument unless code

		# Complete authentication
		begin
			@slots_client.auth_code_callback(code)
		rescue OAuth2::Error => e
			raise AuthenticationFailure.new(e.description)
		end

		"TODO: redirect"
	end
	
	get AUTH_PATH do
		redirect @slots_client.authenticate()
	end

	error MissingArgument do
		|e|
		status 400
		e.message
		redirect HOME_PATH
	end

	error AuthenticationFailure do
		|e|
		status 500
		e.message
		redirect HOME_PATH
	end
end

SlotsApp.start!

