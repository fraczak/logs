openssl genrsa -out priv.pem 1024
openssl rsa -in priv.pem -out pub.pem -outform PEM -pubout
sha1sum priv.pem | cut -d ' ' -s -f 1 > secret.txt
