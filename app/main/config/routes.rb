# See https://github.com/voltrb/volt#routes for more info on routes
# get "/teams/{{__id}}", _action: 'show'
# get '/teams', _action: 'teams'
get '/about', _action: 'about'


# Teams Controller
get '/teams', _controller: 'teams', _action: 'index'
get '/teams/{{__id}}', _controller: 'teams', _action: 'show'


# Routes for login and signup, provided by user-templates component gem
get '/signup', _controller: 'user-templates', _action: 'signup'
get '/login', _controller: 'user-templates', _action: 'login'

# The main route, this should be last. It will match any params not
# previously matched.
get '/', {}
