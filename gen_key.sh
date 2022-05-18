openssl genrsa -aes256 -passout pass:gsahdg -out server.pass.key 4096
openssl rsa -passin pass:gsahdg -in server.pass.key -out server.key
rm server.pass.key

openssl req -new -key server.key -out server.csr -subj "/CN=127.0.0.1"

openssl x509 -req -sha256 -days 365 -in server.csr -signkey server.key -out server.crt