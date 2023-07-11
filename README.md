# Alpine Linux on kvx bootstrap

This contains the Containerfile used to generate an Alpine environment that can be used to run the bootstrap script from aports: https://git.alpinelinux.org/aports/tree/scripts/bootstrap.sh

This needs to run on an Alpine distro because it uses Alpine packaging/build tools.

## How to use this

```bash
$ git clone https://github.com/fallen/alpine-on-kvx
$ cd alpine-on-linux
$ podman build .
```

The podman build command generates an Alpine image and ends up printing a sha1 like `--> ce02e1ac49d`
Then run this to run a container based on the generated image:

```bash
$ podman run -ti ce02e1ac49d sh
/ $ cd ~/aports/scripts/
~/aports/scripts $ ./bootstrap.sh kvx
```

So far it builds the following packages:
* binutils-kvx
* musl-dev

For now it fails at `gcc-pass2-kvx`
