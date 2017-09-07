yum-docker Cookbook
====================
[![Build Status](https://travis-ci.org/st-isidore-de-seville/cookbook-yum-docker.svg?branch=master)](https://travis-ci.org/st-isidore-de-seville/cookbook-yum-docker)
[![Chef Cookbook](https://img.shields.io/cookbook/v/yum-docker.svg)](https://supermarket.chef.io/cookbooks/yum-docker)

Installs/Configures yum Docker Vendor-Specific Repositories.

This cookbook installs & configures yum Docker repositories per
https://get.docker.com/.

Requirements
------------
- Chef 11 or higher
- Ruby 1.9 or higher (preferably from the Chef full-stack installer)
- Network accessible package repositories
- [yum Cookbook](https://supermarket.chef.io/cookbooks/yum)

Attributes
----------
#### yum-docker::default
The default recipe is for installing & configuring the yum Docker repostories.
Any attribute supported by the [yum cookbook](https://github.com/chef-cookbooks/yum#parameters)
is supported by this cookbook and can be used to override attributes in this
cookbook.

Per https://get.docker.com/, there are currently three repositories for Docker:
main, testing & experimental.  Main is the stable repository.  Testing is for
test builds (ie. release candidates).  Experimental is for experimental builds.

- `['yum-docker']['supported-families']`
  - _Type:_ Hash

  - _Description:_

    Platform support for this cookbook and the Docker repository.  Designed
    to be a private attribute however it can be overridden in the case Docker
    supports additional versions and this cookbook has not been updated yet.

    This check was implemented as a result of the repo could be successfully
    installed yet not be valid for a given platform and a Docker package could
    be successfully installed as a result of it being available natively on the
    platform it which it was run which results in a false positive for the
    consumer of the cookbook.

    The hash key is the platform family of the OS.  The secondary hash key is
    the major version of the OS.  If the hash value evaluates to true, the
    platform family/version is considered supported.

  - _Default:_

    ```ruby
    {
      fedora: {
        '20' => true,
        '21' => true,
        '22' => true
      },
      rhel: {
        '6' => true,
        '7' => true,
        '2015' => true # Amazon Linux
      }
    }
    ```
- Docker Main Repo
  - `['yum-docker']['repos']['docker-main-repo']['managed']`
    - _Type:_ Boolean
    - _Description:_ Does this cookbook manage the install of the Docker Main
      Repo?
    - _Default:_ `true`
  - `['yum-docker']['repos']['docker-main-repo']['repositoryid']`
    - _Type:_ String
    - _Description:_ Unique Name for Docker Main Repo
    - _Default:_ `docker-main-repo`
  - `['yum-docker']['repos']['docker-main-repo']['description']`
    - _Type:_ String
    - _Description:_ Description of Docker Main Repo
    - _Default:_ `Docker main Repository`
  - `['yum-docker']['repos']['docker-main-repo']['baseurl']`
    - _Type:_ String
    - _Description:_ URL of Docker Main Repo
    - _Default:_ `https://yum.dockerproject.org/repo/main/#{docker_dist}/#{node['platform_version'].to_i}`
  - `['yum-docker']['repos']['docker-main-repo']['enabled']`
    - _Type:_ Boolean
    - _Description:_ Whether or not the Docker Main Repo is enabled?
    - _Default:_ `true`
  - `['yum-docker']['repos']['docker-main-repo']['gpgcheck']`
    - _Type:_ Boolean
    - _Description:_ Whether or not Docker Main Repo should perform GPG check
      of packages?
    - _Default:_ `true`
  - `['yum-docker']['repos']['docker-main-repo']['gpgkey']`
    - _Type:_ String
    - _Description:_ GPG Key of Docker Stable Repo
    - _Default:_ `file:///etc/pki/rpm-gpg/RPM-GPG-KEY-Docker`
- Docker Testing Repo
  - `['yum-docker']['repos']['docker-testing-repo']['managed']`
    - _Type:_ Boolean
    - _Description:_ Does this cookbook manage the install of the Docker Testing
      Repo?
    - _Default:_ `false`
  - `['yum-docker']['repos']['docker-testing-repo']['repositoryid']`
    - _Type:_ String
    - _Description:_ Unique Name for Docker Testing Repo
    - _Default:_ `docker-testing-repo`
  - `['yum-docker']['repos']['docker-testing-repo']['description']`
    - _Type:_ String
    - _Description:_ Description of Docker Testing Repo
    - _Default:_ `Docker testing Repository`
  - `['yum-docker']['repos']['docker-testing-repo']['baseurl']`
    - _Type:_ String
    - _Description:_ URL of Docker Testing Repo
    - _Default:_ `https://yum.dockerproject.org/repo/testing/#{docker_dist}/#{node['platform_version'].to_i}`
  - `['yum-docker']['repos']['docker-testing-repo']['enabled']`
    - _Type:_ Boolean
    - _Description:_ Whether or not the Docker Testing Repo is enabled?
    - _Default:_ `true`
  - `['yum-docker']['repos']['docker-testing-repo']['gpgcheck']`
    - _Type:_ Boolean
    - _Description:_ Whether or not Docker Testing Repo should perform GPG check
      of packages?
    - _Default:_ `true`
  - `['yum-docker']['repos']['docker-testing-repo']['gpgkey']`
    - _Type:_ String
    - _Description:_ GPG Key of Docker Testing Repo
    - _Default:_ `file:///etc/pki/rpm-gpg/RPM-GPG-KEY-Docker`
- Docker Experimental Repo
  - `['yum-docker']['repos']['docker-experimental-repo']['managed']`
    - _Type:_ Boolean
    - _Description:_ Does this cookbook manage the install of the Docker
      Experimental Repo?
    - _Default:_ `false`
  - `['yum-docker']['repos']['docker-experimental-repo']['repositoryid']`
    - _Type:_ String
    - _Description:_ Unique Name for Docker Experimental Repo
    - _Default:_ `docker-experimental-repo`
  - `['yum-docker']['repos']['docker-experimental-repo']['description']`
    - _Type:_ String
    - _Description:_ Description of Docker Experimental Repo
    - _Default:_ `Docker experimental Repository`
  - `['yum-docker']['repos']['docker-experimental-repo']['baseurl']`
    - _Type:_ String
    - _Description:_ URL of Docker Experimental Repo
    - _Default:_ `https://yum.dockerproject.org/repo/experimental/#{docker_dist}/#{node['platform_version'].to_i}`
  - `['yum-docker']['repos']['docker-experimental-repo']['enabled']`
    - _Type:_ Boolean
    - _Description:_ Whether or not the Docker Experimental Repo is enabled?
    - _Default:_ `true`
  - `['yum-docker']['repos']['docker-experimental-repo']['gpgcheck']`
    - _Type:_ Boolean
    - _Description:_ Whether or not Docker Experimental Repo should perform GPG
      check of packages?
    - _Default:_ `true`
  - `['yum-docker']['repos']['docker-experimental-repo']['gpgkey']`
    - _Type:_ String
    - _Description:_ GPG Key of Docker Experimental Repo
    - _Default:_ `file:///etc/pki/rpm-gpg/RPM-GPG-KEY-Docker`

Usage
-----
#### yum-docker::default
Just include `yum-docker` in your node's `run_list`:

```json
{
  "name": "my_node",
  "run_list": [
    "recipe[yum-docker]"
  ]
}
```

Contributing
------------
1. Fork the repository on GitHub
2. Create a named feature branch (like `add_component_x`)
3. Write your change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using GitHub

Development Environment
-------------------
This repository contains a Vagrantfile which can be used to spin up a
fully configured development environment in Vagrant.  

Vagrant requires the following:
- [VirtualBox](https://www.virtualbox.org/)
- [Vagrant](https://www.vagrantup.com/)

The Vagrant environment for this repository is based on:
- [st-isidore-de-seville/trusty64-rvm-docker](https://atlas.hashicorp.com/st-isidore-de-seville/boxes/trusty64-rvm-docker)

The Vagrant environment will initialize itself to:
- install required Ruby gems
- run integration testing via kitchen-docker when calling `kitchen`

The Vagrant environment can be spun up by performing the following commands:

1. `vagrant up`
2. `vagrant ssh`
3. `cd /vagrant`

Authors
-------------------
- Author:: St. Isidore de Seville (st.isidore.de.seville@gmail.com)

License
-------------------
```text
The MIT License (MIT)

Copyright (c) 2015 St. Isidore de Seville (st.isidore.de.seville@gmail.com)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
