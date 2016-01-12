# Disposable

Disposable is a shell script used to launch a disposable application via
[Firejail][1].

The application will be launched within a Firejail sandbox using a private home
directory on a temporary filesystem.

This may be useful for a number of applications, but was created specifically
with Chromium in mind. To open a [shady site][2] within an isolated and
disposable sandbox -- or simply to help further protect your online banking --
prepend your normal command with `disposable`:

    $ disposable chromium http://www.forbes.com

When using Disposable to run `chromium` or `google-chrome`, the script will
prevent the first run greeting and disable the default browser check.

## Options

### Network

Optionally, the sandbox may be launched with a new network namespace and a
restrictive netfilter by using the `-n` option.

    $ disposable -n

Unless otherwise specified, [NetworkManager][3] will be used to determine the
first connected network interface. This interface will be used to create the
new network namespace. A specific interface may be requested via the `-i`
option (which implies `-n`).

    $ disposable -i eth0

Firejail's default client network filter will be used in the new network
namespace.

```
*filter
:INPUT DROP [0:0]
:FORWARD DROP [0:0]
:OUTPUT ACCEPT [0:0]
-A INPUT -i lo -j ACCEPT
-A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
-A INPUT -p icmp --icmp-type destination-unreachable -j ACCEPT
-A INPUT -p icmp --icmp-type time-exceeded -j ACCEPT
-A INPUT -p icmp --icmp-type echo-request -j ACCEPT
COMMIT
```

### dev

Optionally, a new `/dev` can also be created for the sandbox by using the `-d`
option.

    $ disposable -d

This has the effect of disabling audio input and output, as well as any webcams.

[1]: https://github.com/netblue30/firejail
[2]: http://www.engadget.com/2016/01/08/you-say-advertising-i-say-block-that-malware/
[3]: https://wiki.gnome.org/Projects/NetworkManager
