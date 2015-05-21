openssl genrsa -out priv.pem 1024
openssl rsa -in priv.pem -out pub.pem -outform PEM -pubout
