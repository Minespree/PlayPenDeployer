# PlayPen deployer

[![Discord](https://img.shields.io/discord/352874955957862402.svg)](https://discord.gg/KUFmKXN)
[![License](https://img.shields.io/github/license/Minespree/PlayPenDeployer.svg)](LICENSE)
[![Documentation](https://img.shields.io/badge/docs-available-brightgreen.svg)](https://github.com/Minespree/Docs)

This repo contains the following:

* Default GitLab CI config files used for automatic compiling, packaging and deployment by PlayPen (stored in [`example`](example/))
* A Docker image which packages JARs with `playpen-p3` and uploads them to PlayPen (stored in [`image`](image/)). Contains a README file explaining how it works. [Image build instructions](#how-do-i-build-the-docker-image)
* A Node.js script which deploys the PlayPen artifact to a private Maven repo (stored in [`mavenDeploy`](mavenDeploy))

Besides the removal of some branding and configuration data, it is more or less unmodified. It is probably not _directly_ useful to third parties in its current state, but it may be help in understanding how the Minespree network operated.

We are quite open to the idea of evolving this into something more generally useful. If you would like to contribute to this effort, talk to us in [Discord](https://discord.gg/KUFmKXN).

Please note that this project might have legacy code that was planned to be refactored and as so, we kindly ask you not to judge the programming skills of the author(s) based on this single codebase.

## Requirements

To use PlayPen deployer, the following will need to be installed and available from your shell:

* [JDK 8](http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html) version 131 or later (older versions _might_ work)
* [Git](https://git-scm.com/)
* [Maven](https://maven.apache.org/)
* [Docker](https://docs.docker.com/install/)

You can find detailed installation instructions for these tools on the [Getting started](https://github.com/Minespree/Docs/blob/master/setup/DEPENDENCIES.md) docs page.

## Getting started

The GitLab CI config has four stages:

#### Maven build

Compiles the project with Maven and saves the produced `*.jar` artifacts for 1 week. Even if you don't want to deploy this version, GitLab allows you to download these artifacts on a `.zip` or `.tar.gz` file which you can manually view and deploy.

#### Maven deploy

This phase should only be used with library projects. Deploys the Maven project to a private Maven repository, so you can remove it if you don't want to deploy the artifacts anywhere.

#### PlayPen test

Updates the cached PlayPen packages repo, packages the produced artifacts on the **Build stage** with `playpen-p3` and deploys them to the dev network, which you will have to configure:

1.  Go to your project settings and click on "CI / CD Settings".
2.  Click on "Secret variables" and define `PP_DEV_UUID`, `PP_DEV_KEY`, `PP_DEV_IP`, `PP_DEV_PORT`, `PP_DEV_USER` and `PP_DEV_SSH_KEY`.
3.  Push a commit to any branch and check that a CI pipeline has started.

This phase needs to be run manually from GitLab, as you may not want to deploy
something before ensuring you didn't commit any mistakes.

#### PlayPen deploy

Updates the cached PlayPen packages repo, repackages the produced artifacts on the **Build stage** with `playpen-p3` and deploys them to the main network, which you will have to configure:

1.  Go to your project settings and click on "CI / CD Settings".
2.  Click on "Secret variables" and define `PP_PROD_UUID`, `PP_PROD_KEY`, `PP_PROD_IP`, `PP_PROD_PORT`, `PP_PROD_USER` and `PP_PROD_SSH_KEY`.
3.  Change the build stage env variable `PP_TYPE` to `"PROD"`.
4.  Push a commit to the `master` branch and check that a CI pipeline has started.

This phase needs to be run manually from GitLab, as you may not want to deploy
something before ensuring you didn't commit any mistakes.

Please note that you can only deploy to production if the commit has been merged to the `master` branch. The reasoning behind this is that we always want an updated main branch which works.

### How do I create a new package?

Create a `your_project_name` directory on the `playpen-packages` repo, add the
PlayPen `package.json` metadata file and copy any additional config files/maps which
will be parsed by PlayPen and will be deployed.

Finally, add the `.gitlab-ci.yml` config to your project directory, optionally modify your `pom.xml` and `plugin.yml` if you want the plugin's version to be the last commit #, set the PlayPen secret variables and then commit and push your changes.

### How do I build the Docker image?

Check the image [`README`](image/README.md) file for prebuilding (e.g. creating the required SSH keys and adding them to the `playpen-packages` repo) and building instructions.

## Authors

This project was maintained by the Minespree Network team. If you have any questions or problems, feel free to reach out to the specific writers and maintainers of this project:

<table>
  <tbody>
    <tr>
      <td align="center">
        <a href="https://github.com/hugmanrique">
          <img width="150" height="150" src="https://github.com/hugmanrique.png?v=3&s=150">
          </br>
          Hugmanrique
        </a>
      </td>
    </tr>
  <tbody>
</table>

## Coding Conventions

* We generally follow the Sun/Oracle coding standards.
* No tabs; use 4 spaces instead
* No trailing whitespaces
* No CRLF line endings, LF only, put your git's `core.autocrlf` on `true`.
* No 80 column limit or 'weird' midstatement newlines.

## License

PlayPen deployer is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.

A copy of the GNU Affero General Public License is included in the file LICENSE, and can also be found at https://www.gnu.org/licenses/agpl-3.0.en.html

**The AGPL license is quite restrictive, please make sure you understand it. If you run a modified version of this software as a network service, anyone who can use that service must also have access to the modified source code.**
