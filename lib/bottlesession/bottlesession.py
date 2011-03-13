# -*- coding: utf-8 -*-
#  From https://github.com/linsomniac/bottlesession/blob/master/bottlesession.py
#
#  Bottle session manager.  See README for full documentation.
#
#  Written by: Sean Reifschneider <jafo@tummy.com>
#  Changes by: Matthew Holloway <matthew@holloway.co.nz>

from __future__ import with_statement
import os
import os.path
import pickle
import uuid
import hashlib
import time

try:
    import bottle
except ImportError:
    lib_directory = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    sys.path.append(os.path.join(lib_directory, 'bottle'))
    try:
        import bottle
    except ImportError:
        sys.stderr.write("Error: Unable to find Bottle libraries in %s. Exiting..." % sys.path)
        sys.exit(0)

class BaseSession(object):
	'''Base class which implements some of the basic functionality required for
	session managers.  Cannot be used directly.

	:param cookie_expires: Expiration time of session ID cookie, either `None`
			if the cookie is not to expire, a number of seconds in the future,
			or a datetime object.  (default: 30 days)
	'''
	def __init__(self, cookie_expires = 86400*30):
		self.cookie_expires = cookie_expires

	def load(self, sessionid):
		raise NotImplementedError

	def save(self, sessionid, data):
		raise NotImplementedError

	def make_session_id(self):
		return str(uuid.uuid4())

	def allocate_new_session_id(self):
		#  retry allocating a unique sessionid
		for i in xrange(100):
			sessionid = self.make_session_id()
			if not self.load(sessionid): return sessionid
		raise ValueError('Unable to allocate unique session')

	def get_session(self):
		#  get existing or create new session identifier
		sessionid = bottle.request.COOKIES.get('sessionid')
		if not sessionid:
			sessionid = self.allocate_new_session_id()
			bottle.response.set_cookie('sessionid', sessionid,
					path = '/', expires = self.cookie_expires)
		#  load existing or create new session
		data = self.load(sessionid)
		if not data:
			data = { 'sessionid' : sessionid, 'valid' : False }
			self.save(data)
		return data


class PickleSession(BaseSession):
	'''Class which stores session information in the file-system.

	:param session_dir: Directory that session information is stored in.
			(default: ``'/tmp'``).
	'''
	def __init__(self, session_dir = '/tmp', *args, **kwargs):
		super(PickleSession, self).__init__(*args, **kwargs)
		self.session_dir = session_dir

	def load(self, sessionid):
		filename = os.path.join(self.session_dir, 'docvert-session-%s' % sessionid)
		if not os.path.exists(filename): return None
		with open(filename, 'r') as fp: session = pickle.load(fp)
		return session

	def save(self, data):
		sessionid = data['sessionid']
		fileName = os.path.join(self.session_dir, 'docvert-session-%s' % sessionid)
		tmpName = fileName + '.' + str(uuid.uuid4())
		with open(tmpName, 'w') as fp: self.session = pickle.dump(data, fp)
		os.rename(tmpName, fileName)


class CookieSession(BaseSession):
	'''Session manager class which stores session in a signed browser cookie.

	:param cookie_name: Name of the cookie to store the session in.
			(default: ``session_data``)
	:param secret: Secret to be used for "secure cookie".  If ``None``,
			attempts will be made to generate a difficult to guess secret.
			However, this is probably only suitable for private web apps, and
			definitely only for a single web server.  You really should be
			using your own secret.  (default: ``None``)
	:param secret_file: File to read the secret from.  If ``secret`` is
			``None`` and ``secret_file`` is set, the first line of this file
			is read, and stripped, to produce the secret.
	'''

	def __init__(self, secret = None, secret_file = None, cookie_name = 'docvert_session', *args, **kwargs):
		super(CookieSession, self).__init__(*args, **kwargs)
		self.cookie_name = cookie_name
		if not secret and secret_file is not None:
			with open(secret_file, 'r') as fp:
				secret = fp.readline().strip()
		if not secret: 	#  generate a difficult to guess secret
			secret = str(uuid.uuid1()).split('-', 1)[1]
			with open('/proc/uptime', 'r') as fp:
				uptime = int(time.time() - float(fp.readline().split()[0]))
				secret += '-' + str(uptime)
			secret = hashlib.sha1(secret).hexdigest()
		self.secret = secret

	def load(self, sessionid):
		cookie = bottle.request.get_cookie(self.cookie_name, secret = self.secret)
		if cookie == None: return {}
		return pickle.loads(cookie)

	def save(self, data):
		bottle.response.set_cookie(
            self.cookie_name,
            pickle.dumps(data),
		    secret = self.secret, path = '/', expires = self.cookie_expires)

