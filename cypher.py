import os
import sys
from Crypto.PublicKey import RSA
from Crypto.Cipher import PKCS1_OAEP

if not os.path.exists('private_key.pem') or not os.path.exists('public_key.pem'):
    # Générer une paire de clés RSA
    key = RSA.generate(2048)

    # Exporter la clé publique
    public_key = key.publickey().export_key()
    with open('public_key.pem', 'wb') as f:
        f.write(public_key)

    # Exporter la clé privée
    private_key = key.export_key()
    with open('private_key.pem', 'wb') as f:
        f.write(private_key)

def main(password: str):
    # Charger la clé publique depuis un fichier
    with open('public_key.pem', 'r') as f:
        public_key = RSA.import_key(f.read())
    # Chiffrer le mot de passe avec la clé publique
    cipher = PKCS1_OAEP.new(public_key)
    encrypted_password = cipher.encrypt(password.encode()).hex()
    print(encrypted_password, end='')

if __name__ == '__main__':
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <password>")
        sys.exit(1)
    main(sys.argv[1])