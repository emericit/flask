import csv
import random
from flask import Flask, make_response, request, Response, jsonify
from pydantic import BaseModel
from flask_pydantic import validate
from Crypto.PublicKey import RSA
from Crypto.Cipher import PKCS1_OAEP
from typing import Tuple, Union
from vaderSentiment.vaderSentiment import SentimentIntensityAnalyzer

analyzer = SentimentIntensityAnalyzer()

class Query(BaseModel):
    sentence:str

app = Flask(__name__)

def decipher(encrypted_password: str) -> str:
    """Decrypt the password using the private key"""
    with open('private_key.pem', 'r') as f:
        private_key = RSA.import_key(f.read())
    cipher = PKCS1_OAEP.new(private_key)
    return cipher.decrypt(bytes.fromhex(encrypted_password)).decode()

@app.route("/status")
def hello() -> Response:
    """Health monitoring endpoint"""
    return make_response(jsonify(1), 200)

@app.route("/welcome/<string:name>")
def welcome(name: str) -> Response:
    """Welcome endpoint"""
    return make_response(jsonify(f"Bonjour {name}"), 200)

@app.route("/public_key")
def public_key() -> Response:
    """Public key endpoint: returns the public key in PEM format, 
    in a JSON object with the key 'public_key'"""
    try:
        with open('public_key.pem', 'r') as f:
            public_key = RSA.import_key(f.read())
        data = {'public_key': public_key.export_key().decode()}
        return make_response(jsonify(data), 200)
    except FileNotFoundError:
        return make_response(jsonify("No public key found"), 500)
    
def extract_header(header: dict) -> Union[Tuple[str, str], Response]:
    """Extract the username and password from the header.
    Authentication is expected in the header {Authentication: username:password}.
    Returns a tuple (username, password) if everything goes well, or a Response object
    when there is an error"""
    if 'Authentication' not in header:
        return make_response(jsonify("Missing Authentication header"), 400)
    else:
        try:
            username, password = decipher(header['Authentication']).split(':', maxsplit=1)
        except ValueError:
            return make_response(jsonify("Invalid Authentication header. Expected"
                                 " Authentication: <username:password>"), 400)
        return username, password
    
def authenticate(username: str, password: str) -> Union[Response, dict]:
    """Authenticate the user. Reads from the CSV file 'credentials.csv' and compares to username
    and password.
    Returns True if the user is authenticated, or a Response object when there is an error (invalid
    user, invalid password, etc.))"""
    try:
        with open('credentials.csv', 'r') as f:
            reader = csv.DictReader(f)
            for line in reader:
                if line['username'] == username:
                    if line['password'] == password:
                        return line
                    else:
                        return make_response(jsonify("Invalid password"), 403)
            if username not in [row['username'] for row in reader]:
                return make_response(jsonify("Invalid user"), 403)
    except FileNotFoundError:
        return make_response(jsonify("No credentials found"), 500)
    
# je pense qu'on peut autoriser les méthodes GET et POST pour /permissions
# l'authentification se fait avec le header Authentication, donc c'est possible
# avec les deux méthodes
@app.route("/permissions", methods=['POST'])
def permissions():
    """Permissions endpoint: returns the permissions of the user.
    Authentication in expected in the header {Authentication: username=password}"""
    header = dict(request.headers)
    from_header = extract_header(header)
    if type(from_header) == Response:
        return from_header
    else:
        username, password = from_header
        from_credentials = authenticate(username, password)
        if type(from_credentials) == Response:
            return from_credentials
        else:
            v1 = from_credentials['v1']
            v2 = from_credentials['v2']
            data = {'username': username, 'v1': int(v1), 'v2': int(v2)}
            return make_response(jsonify(data), 200, data)
        
@app.route("/v1/sentiment", methods=['POST'])
@validate()
def sentiment_v1(body: Query):
    """Sentiment endpoint v1: returns the sentiment of the sentence in the
    query parameters.
    Authentication in expected in the header {Authentication: username=password}"""
    header = dict(request.headers)
    from_header = extract_header(header)
    if type(from_header) == Response:
        return from_header
    else:
        username, password = from_header
        from_credentials = authenticate(username, password)
        if type(from_credentials) == Response:
            return from_credentials
        else:
            v1 = from_credentials['v1']
            if v1 != '1':
                return make_response(jsonify("User does not have permission v1"), 403)
            if 'sentence' not in body.dict():
                return make_response(jsonify("Missing sentence in body"), 400)
            sentence = body.dict()['sentence']
            score = random.uniform(-1, 1)
            if score >= 0.05:
                sentiment = 'positive'
            elif score <= -0.05:
                sentiment = 'negative'
            else:
                sentiment = 'neutral'
            data = {'username': username, 
                    'version': 'v1', 
                    'sentence': sentence, 
                    'sentiment': sentiment,
                    'score': score}
            return make_response(jsonify(data), 200, data)
        
@app.route("/v2/sentiment", methods=['POST'])
@validate()
def sentiment_v2(body: Query):
    """Sentiment endpoint v2: returns the sentiment of the sentence in the
    query parameters.
    Authentication in expected in the header {Authentication: username=password}"""
    header = dict(request.headers)
    from_header = extract_header(header)
    if type(from_header) == Response:
        return from_header
    else:
        username, password = from_header
        from_credentials = authenticate(username, password)
        if type(from_credentials) == Response:
            return from_credentials
        else:
            v2 = from_credentials['v2']
            if v2 != '1':
                return make_response(jsonify("User does not have permission v1"), 403)
            if 'sentence' not in body.dict():
                return make_response(jsonify("Missing sentence in body"), 400)
            sentence = body.dict()['sentence']
            score = analyzer.polarity_scores(sentence)['compound']
            if score >= 0.05:
                sentiment = 'positive'
            elif score <= -0.05:
                sentiment = 'negative'
            else:
                sentiment = 'neutral'
            data = {'username': username, 
                    'version': 'v2', 
                    'sentence': sentence, 
                    'sentiment': sentiment,
                    'score': score}
            return make_response(jsonify(data), 200, data)
        