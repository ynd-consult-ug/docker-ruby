# docker-ruby

This repository provides Dockerfiles for Alpine and CentOS based images with Ruby. Dockerfiles are generated with pre-commit git hook (`./git-hooks/pre-commit`) and corresponding template in the project's root, so one needs to run `git config core.hooksPath git-hooks` first in order to use it.

Alpine template is based on official [docker-library/ruby](https://github.com/docker-library/ruby).
