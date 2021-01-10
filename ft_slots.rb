#!/usr/bin/env ruby
require "oauth2"
require "yaml"
require "sinatra"

get "/callback/:code" do
	|code|
	"Success!"
end

# Get closed projects waiting for evaluations
def projects_get_closed(token)
	projects_data = token.get("/v2/projects_users", params: {page: {number: 2, size: 100}, filter: {final_mark: nil}})
	projects_data.parsed.each {
		|project|
		printf("[%s](%s)\n", project["status"], project["project"]["name"])
	}
end

# Load config
api_url, redirect_uri, uid, secret = YAML.load_file("#{__dir__}/config.yml")
# Get username
#username = ARGV.length == 1 ? ARGV[0] : ENV["USER"]
# Create the client with our credentials
client = OAuth2::Client.new(uid, secret, site: api_url)
# Ask the user to grant permissions
auth_url = client.auth_code.authorize_url(redirect_uri: redirect_uri)
printf("Authorize using %s\n", auth_url)

# Get an access token
token = client.client_credentials.get_token

# projects_get_closed(token)
