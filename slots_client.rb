require "yaml"
require "oauth2"

class SlotsClient
    def initialize(config_filepath, callback_uri)
        # Set callback URI
		@callback_uri = callback_uri
		# Load config
		api_url, uid, secret = YAML.load_file(config_filepath)
		# Create the client with our credentials
		@client = OAuth2::Client.new(uid, secret, :site => api_url)
		@authenticated = false
	end

    def authenticate()
        # Ask the user to grant permissions
		auth_url = @client.auth_code.authorize_url(:redirect_uri => @callback_uri)
		printf("Authorize using %s\n", auth_url)

		# Get an access token
        return auth_url
    end

    def auth_code_callback(code)
        @token = @client.auth_code.get_token(code, :redirect_uri => @callback_uri)
		authenticated = true
	end

	# Get closed projects waiting for evaluations
	def projects_get_closed()
		params = {page: {number: 2, size: 100}, filter: {final_mark: nil}}
		projects_data = @token.get("/v2/projects_users", :params => params)
		projects_data.parsed.each {
			|project|
			printf("[%s](%s)\n", project["status"], project["project"]["name"])
		}
	end
end