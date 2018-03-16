# PlayPen Maven deploy

This Node.js script packages the PlayPen project (from GitHub) and deploys the produced artifacts to a private Maven repo.

## Installation

You need to have Node 8.10+ in order to run this script. First, install the npm dependencies by running:

```shell
# npm users
npm i
# yarn users
yarn
```

Next, setup the Maven repo you want to deploy the artifacts to. Open up the `index.js` file and change the `repositories` config (you can add multiple repositories):

```javascript
repositories: [
  {
    id: 'awesome-release',
    url: 'https://example.com/maven/libs-release'
  }
];
```

You will also need to change the `releaseDeployRepo` variable to the repo # you want to deploy the artifacts to (in this case `awesome-release`).

Then, run the `install.sh` script which will clone the PlayPen repo from GitHub (via `HTTPS`) to the `dist/` directory.

## Usage

Run the `deploy.sh` script which will reset your changes, pull from `master`, package the PlayPen artifact, install it on your local Maven repo and finally deploy it to our private Maven repo. You will need to have setup your Maven repo credentials; if you haven't you can learn how to do it on the [Artifactory setup](https://github.com/Minespree/Docs/blob/master/setup/ARTIFACTORY.md) page on the Docs repo.

Whenever a PlayPen update is released, simply run the `deploy.sh` script and that will deploy the latest version to the Maven repo. You can also pass the `--skipPackage` flag to skip the package phase and just deploy the previous produced artifact.
