# KDC Container

This creates a docker image for a simple KDC server. The container will run kadmind and the kdc.

The current admin password for "root/admin" is "password" and if you kinit with this credential you can create or destroy any principals on the server.

At the moment, there are no configurabled options and the container expected to be running with a hostname of "kdc".
