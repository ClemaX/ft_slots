#!/usr/bin/env ruby
require "oauth2"
require "yaml"

# Get closed projects waiting for evaluations
def projects_get_closed(token)
	projects_data = token.get("/v2/projects_users", params: {page: {number: 2, size: 100}})
	projects_data.parsed.each {
		|project|
		printf("[%s](%s): %d\n", project["status"], project["project"]["name"], project["project"]["final_mark"])
	}
end

# Load config
url, uid, secret = YAML.load_file("#{__dir__}/config.yml")
# Get username
username = ARGV.length == 1 ? ARGV[0] : ENV["USER"]
# Create the client with our credentials
client = OAuth2::Client.new(uid, secret, site: url)
# Get an access token
token = client.client_credentials.get_token

projects_get_closed(token)
