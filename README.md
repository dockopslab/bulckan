# bulckan

This project provides a GitOps tool for Docker Compose on a Docker container.

The application clones a GitHub repository, periodically checks for changes to a specific branch and path, and deploys or updates the project using Docker Compose.

[![bulckanCI](https://github.com/dockopslab/bulckan/actions/workflows/bulckanCI.yml/badge.svg?branch=main)](https://github.com/dockopslab/bulckan/actions/workflows/bulckanCI.yml)

## Requirements:
- Docker
- Docker Compose
- Access to a GitHub repository (public or private)

bulckan only monitors changes in the specified path and will only update the configuration of the docker compose file. It does not monitor if images have been updated, use [Watchtower](https://containrrr.dev/watchtower/?ref=selfh.st) for that by deploying it with bulckan.

Note: To test the functionality, it is possible to deploy bulckan as configured. The application points to a branch of the same repository with the Docker Compose files needed to deploy an Apache container.

## Configuration
First, clone this repository and navigate to the project directory:

```
git clone https://github.com/dockopslab/bulckan.git
cd bulckan
```

Configure the ``.env`` file to access the repository, branch and path where the docker-compose.yml file you want to deploy and maintain with this tool is located:

```
GITHUB_URL=github.com/dockopslab/bulckan.git
GITHUB_BRANCH=example/bulckan-target
GITHUB_PATH=sample/
CHECK_INTERVAL=60
GITHUB_USERNAME=
GITHUB_TOKEN=
```
Bulckan deployment:

```
docker compose up -d
```

The application will clone the repository and display the docker-compose.yml of the specified branch and path:

```
Cloning repository...
Cloning into 'repo'...
Deploying with docker-compose...
time="2024-08-05T20:55:10Z" level=warning msg="/repo/sample/
 apache1 Pulling 
 efc2b5ad9eec Pulling fs layer 
 fce1785eb819 Pulling fs layer 
 4f4fb700ef54 Pulling fs layer 
 f214daa0692f Pulling fs layer 
 05383fd8b2b3 Pulling fs layer 
 88ad12232aa1 Pulling fs layer 
 f214daa0692f Waiting 
 88ad12232aa1 Waiting 
 05383fd8b2b3 Waiting 
 fce1785eb819 Downloading [==================================================>]     145B/145B
 fce1785eb819 Verifying Checksum 
 fce1785eb819 Download complete 
 4f4fb700ef54 Downloading [==================================================>]      32B/32B
 4f4fb700ef54 Verifying Checksum 
 4f4fb700ef54 Download complete 
 efc2b5ad9eec Downloading [>                                                  ]  294.2kB/29.13MB
 efc2b5ad9eec Downloading [=========>                                         ]  5.339MB/29.13MB
 efc2b5ad9eec Downloading [================>                                  ]  9.779MB/29.13MB
 efc2b5ad9eec Downloading 
 ..........
 [==================================================>]     291B/291B
 88ad12232aa1 Extracting [==================================================>]     291B/291B
 88ad12232aa1 Pull complete 
 apache1 Pulled 
 Container sample-apache1-1  Creating
 Container sample-apache1-1  Created
 Container sample-apache1-1  Starting
 Container sample-apache1-1  Started
Sleeping for 60 seconds...
```

# Multiple deployment configuration

bulckan can be deployed multiple times, so it can point to different repositories and keep different applications updated and deployed at the same time.

Configure .git.env file if necessary:
```
GITHUB_USERNAME=
GITHUB_TOKEN=
```

Configure environment variables in docker-compose.example.yml:
```
version: '3.8'

services:
  bulckan1:
    image: ghcr.io/dockopslab/bulckan:latest
    env_file:
      - .git.env
    environment:
      - GITHUB_URL=github.com/dockopslab/bulckan.git
      - GITHUB_BRANCH=example/bulckan-target
      - GITHUB_PATH=watchtower/
      - CHECK_INTERVAL=3600
      - GITHUB_USERNAME=${GITHUB_USERNAME}
      - GITHUB_TOKEN=${GITHUB_TOKEN}
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
  
  bulckan2:
    image: ghcr.io/dockopslab/bulckan:latest
    env_file:
      - .git.env
    environment:
      - GITHUB_URL=github.com/dockopslab/bulckan.git
      - GITHUB_BRANCH=example/bulckan-target
      - GITHUB_PATH=sample/
      - CHECK_INTERVAL=120
      - GITHUB_USERNAME=${GITHUB_USERNAME}
      - GITHUB_TOKEN=${GITHUB_TOKEN}
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock

....
```

Bulckan deployment:

```
docker-compose -f docker-compose.example.yml up -d
```

Note: Before deploying multiple docker-compose.yml with Bulckan, it is necessary to check for possible incompatibilities. Errors due to duplication of exposed ports, service names, networks, and others must be corrected before deployment.

## Contributions
Contributions are welcome. Please open an issue or send a pull request to improve this project.

## License
This project is licensed under the GPL-2.0 license. See the LICENSE file for more details.