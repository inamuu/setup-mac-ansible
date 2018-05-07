from workflow import PasswordNotFound

from wunderlist import config
from wunderlist.util import relaunch_alfred, workflow


def authorize():
    from multiprocessing import Process
    import urllib
    import webbrowser

    workflow().store_data('auth', 'started')

    state = new_oauth_state()
    data = urllib.urlencode({
        'client_id': config.WL_CLIENT_ID,
        'redirect_uri': 'http://localhost:6200',
        'state': state
    })
    url = '%s/%s?%s' % (config.WL_OAUTH_URL, 'authorize', data)

    # Start a server to await the redirect URL request after authorizing
    server = Process(target=await_token)
    server.start()

    # Open the authorization prompt in the default web browser
    webbrowser.open(url)


def deauthorize():
    try:
        workflow().delete_password(config.KC_OAUTH_TOKEN)
    except PasswordNotFound:
        pass


def is_authorized():
    return oauth_token() is not None


def handle_authorization_url(url):
    import urlparse

    # Parse query data & params to find out what was passed
    parsed_url = urlparse.urlparse(url)
    params = urlparse.parse_qs(parsed_url.query)

    # request is either for a file to be served up or our test
    if 'code' in params and validate_oauth_state(params['state'][0]):
        # Request a token based on the code
        resolve_oauth_token(params['code'][0])
        workflow().store_data('auth', None)

        print 'You are now logged in'
        return True
    elif 'error' in params:
        workflow().store_data('auth', 'Error: %s' % params['error'])

        print 'Please try again later'
        return params['error']

    # Not a valid URL
    return False


def oauth_token():
    try:
        return workflow().get_password(config.KC_OAUTH_TOKEN)
    except PasswordNotFound:
        return None


def client_id():
    return config.WL_CLIENT_ID


def oauth_state():
    try:
        return workflow().get_password(config.KC_OAUTH_STATE)
    except PasswordNotFound:
        return None


def new_oauth_state():
    import random
    import string

    state_length = 20
    state = ''.join(
        random.SystemRandom().choice(string.ascii_uppercase + string.digits)
        for _ in range(state_length))

    workflow().save_password(config.KC_OAUTH_STATE, state)

    return state


def validate_oauth_state(state):
    return state == oauth_state()


def resolve_oauth_token(code):
    import requests

    url = '%s/%s' % (config.WL_OAUTH_URL, 'access_token')
    data = {
        'code': code,
        'client_id': config.WL_CLIENT_ID,
        'client_secret': config.WL_CLIENT_SECRET
    }

    res = requests.post(url=url, data=data)
    token_info = res.json()

    workflow().save_password(config.KC_OAUTH_TOKEN, token_info['access_token'])
    workflow().delete_password(config.KC_OAUTH_STATE)


def await_token():
    import SimpleHTTPServer
    import SocketServer

    class OAuthTokenResponseHandler(SimpleHTTPServer.SimpleHTTPRequestHandler):

        def do_GET(self):
            auth_status = handle_authorization_url(self.path)

            if not auth_status:
                self.path = 'www/' + self.path
            elif auth_status is True:
                self.path = 'www/authorize.html'
            else:
                self.path = 'www/decline.html'

            SimpleHTTPServer.SimpleHTTPRequestHandler.do_GET(self)

            relaunch_alfred()

    server = SocketServer.TCPServer(
        ("", config.OAUTH_PORT), OAuthTokenResponseHandler)

    server.timeout = config.OAUTH_TIMEOUT
    server.handle_request()
