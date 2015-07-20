#openssl genrsa -out priv.pem 4096
#openssl genpkey -out priv.pem -outform PEM -algorithm RSA -text -pkeyopt rsa_keygen_bits:16781 -pkeyopt rsa_keygen_pubexp:169733
openssl genpkey -out priv.pem -outform PEM -algorithm RSA -text -pkeyopt rsa_keygen_bits:15000 -pkeyopt rsa_keygen_pubexp:69733
openssl rsa -in priv.pem -out pub.pem -outform PEM -pubout
sha1sum priv.pem | cut -d ' ' -s -f 1 > secret.txt
