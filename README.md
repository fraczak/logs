Logs
====

`Logs` is a container for data. For a single person, it would be a log
(chain) of messages, piece of information called `log`. If you want
to keep a log secret, you encode it with your public key. If you
send it to another person, encode it with his/her public key. Or, just
keep it in clear so everybody can read it.

`Logs` is a rooted tree of `logs`. Every `log`, except root,
contains a reference to its parent and it is signed with a private key of
the author.

       log = {
           parent: hexString hash(parent_log),
           data  : String
           author: PublicKeyPemString,
           sign  : sign([this.parent, this.data], private_key)
       }

That's it.

The idea is that people willing to communicate share a `log-tree`,
which is a monotonous and conflict-free data structure. Any kind of
policies could be applied to limit trim the tree; for example
considering only logs which are signed with one of a selected set of
keys, etc...

Using `Logs` as a mailbox
-------------------------

Who needs gmail?

1. Generate a root with data containing:

   a. receipt for how to find peers, e.g., a bunch of tor nodes with
      list of known peers

   b. a standard for formatting `data` part of a `message`, e.g.,:
      something like:

         data: {
           to   : publicKeyTo,
           msg  : encrypt(text,publicKyeTo)
         }

      or, even better, a simple js app for formatting messages

   c. your public key

2. Share the root with people you want to keep in touch with

3. You are done, as long as you keep syncing your copy of the tree
   with others

Questions:
==========

Q. Why tree and not a list for every public key?

A. A tree is a list. You may try to organize your system like that,
   but then you will have to solve the following problem:

      What to do if your local copy of a list is different from what
      your peer has?

