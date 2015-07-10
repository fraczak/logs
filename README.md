Logs
====

`Logs` is a container for data. For a single person, it would be a
collection of messages, piece of information called `log`. If you want
to keep a log secret, you encode it with your public key. If you send
it to another person, encode it with his/her public key. Or, just keep
it in clear so everybody can read it.

Every `log` is signed with a private key of the author.

       log = {
           data  : String
           author: PublicKeyPemString,
           sign  : sign([this.parent, this.data], private_key)
       }

That's it.

The idea is that people willing to communicate share `logs`,
which is a monotonous and conflict-free data structure. Any kind of
policies could be applied to limit trim the collection; for example
considering only logs which are signed with one of a selected set of
keys, etc...

Using `Logs` as a mailbox
-------------------------

Who needs gmail?

1. Generate a log with data containing:

   a. receipt for how to find peers, e.g., a bunch of tor nodes with
      list of known peers

   b. a standard for formatting `data` part of a `message`, e.g.,:
      something like:

         data: {
           to   : publicKeyTo,
           msg  : encrypt(text,publicKyeTo)
         }

2. Share the log with people you want to keep in touch with

3. You are done, as long as you keep syncing your copy of the
   collection with others

Using `Logs` as address book (`yp`)
-----------------------------------

1. Create a new pair of public/private keys just for `yp`

2. Create a `log` signed by `yp` private key with the collection of addresses,
   i.e., something like:

        data: {
          yp : [{name:"Wojtek", key: "MIGfMA0GCSqGS...", ... }, ...]
        }

3. Now, if you want to access your `yp`, just find the `log` by `yp` public key,
   or by the hash of the `log`.


Running two servers locally
=============================

As a bootstrap for testing, I use two servers in two different directories (so the `./public/logs` subdirectory are different for the two servers).

    ~/logs >
      cd ..
      cp -a logs logs_bis
      sed 's/port\([ ]*\): 3333/port\1: 4444/' logs/conf.coffee > logs_bis/conf.coffee
      sed 's/127.0.0.1:4444/127.0.0.1:3333/' logs/peers.coffee > logs_bis/peers.coffee
      cd logs_bis/private
      . gen_key.sh
      cd ..
      coffee index.coffee &
      cd ../logs
      coffee index.coffee &

Now, the server in `~/logs/` listens on port `3333` and expects a peer at `127.0.0.1:4444`.
The server in `~/logs_bis/` listens on `4444` and expects a peer at `127.0.0.1:3333`.
