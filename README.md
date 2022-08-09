# TestWork

All this was studied and completed in one day, since nothing like this had ever been done before.
At the moment I'm not sure if it works.

[Install docker on your machine.][install-docker]

[Install docker-compose on your machine.][install-docker-compose]

Clone this repository.

``` bash
$ git clone https://github.com/DmitroKriuchkov/TestWork.git
```

Switch to the cloned directory.

``` bash
$ cd TestWork
```

Run the init script:

``` bash
$ ./init-letsencrypt.sh
```

Start the stack.

``` bash
$ docker-compose up
```

Add iptables rules to autoruns:

``` bash
$ chmod +x iptables_ruls.sh
```
and
``` bash
$ echo "/sbin/iptables-restore < /iptables_ruls.sh " >> /etc/rc.d/rc.local
```

[install-docker]: https://docs.docker.com/engine/installation
[install-docker-compose]: https://docs.docker.com/compose/install
