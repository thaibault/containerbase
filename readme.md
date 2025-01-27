<!-- !/usr/bin/env markdown
-*- coding: utf-8 -*-
region header
Copyright Torben Sickert (info["~at~"]torben.website) 16.12.2012

License
-------

This library written by Torben Sickert stand under a creative commons naming
3.0 unported license. See https://creativecommons.org/licenses/by/3.0/deed.de
endregion -->

Project status
--------------

[![npm](https://img.shields.io/npm/v/containerbase?color=%23d55e5d&label=npm%20package%20version&logoColor=%23d55e5d&style=for-the-badge)](https://www.npmjs.com/package/containerbase)
[![npm downloads](https://img.shields.io/npm/dy/containerbase.svg?style=for-the-badge)](https://www.npmjs.com/package/containerbase)

[![build push package](https://img.shields.io/github/actions/workflow/status/thaibault/containerbase/build-package-and-push.yaml?label=build%20push%20package&style=for-the-badge)](https://github.com/thaibault/containerbase/actions/workflows/build-package-and-push.yaml)
[![build push image](https://img.shields.io/github/actions/workflow/status/thaibault/containerbase/build-image-and-push-periodically-1.yaml?label=build%20push%20image&style=for-the-badge)](https://github.com/thaibault/containerbase/actions/workflows/build-image-and-push-periodically-1.yaml)

[![test](https://img.shields.io/github/actions/workflow/status/thaibault/containerbase/test.yaml?label=test&style=for-the-badge)](https://github.com/thaibault/containerbase/actions/workflows/test.yaml)

[![documentation website](https://img.shields.io/website-up-down-green-red/https/torben.website/containerbase.svg?label=documentation-website&style=for-the-badge)](https://torben.website/containerbase)

<!--|deDE:Einsatz-->
Use case
--------

A basic ArchLinux based docker configuration with configured and ready to use
git and yay.

### Jump into the image interactively

```bash
docker run --entrypoint /usr/bin/bash --interactive --tty tsickert/containerbase
```

### Run a process

```bash
docker run --env COMMAND=/path/to/executable/file tsickert/containerbase
```
