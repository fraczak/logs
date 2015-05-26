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

      or, even better, a simple js app for formatting messages

2. Share the log with people you want to keep in touch with

3. You are done, as long as you keep syncing your copy of the
   collection with others

