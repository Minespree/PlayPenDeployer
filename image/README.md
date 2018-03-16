# GitLab CI PlayPen Runner

This Docker image takes care of packaging produced artifacts by Maven with `playpen-p3`, moving them into an updated directory of [`playpen-packages`](https://github.com/Minespree/Docs/blob/master/deploy/PLAYPEN_PACKAGES.md) in the `runner` branch and deploying them to the specified PlayPen IP:port address. You can take a look on how to integrate this runner with your project on the [README](../README.md) file.

The script will log the SHA512 hash of `<playpen_ip>:<playpen_port>` so you can check if the package was deployed to the right instance.

## Preinstallation instructions

### Creating your own SSH keys

When the container starts, it will try to clone the PlayPen packages repo stored in GitLab. As you can see, this directory contains a SSH (placeholder) keypair. You can generate your own (assuming you're using Linux, macOS or Git Bash on Windows):

```
ssh-keygen -t rsa -C "playpenDeployer@example.com" -b 4096
```

Don't set a password to unlock the private key as the SSH key usage is going to be automated. Once you have generated it, move them to this directory (the one containing the `Dockerfile`).

**Note:** Your Docker image will contain a private SSH key, which means you shouldn't share it, and that's the main reason why we are only going to give it read-only access to a specific project on GitLab by using the [deploy keys](https://docs.gitlab.com/ce/ssh/README.html#deploy-keys) GitLab feature. Let's set them up!

First, access your `playpen-packages` project, hover over settings and click on "Repository":

![GitLab project sidebar](https://i.hugmanrique.me/UKWCssE.png)

Now, expand the "Deploy Keys" panel and paste the SSH **public** key we generated on the previous step. We don't need to enable write access as the Docker image is just going to clone and pull contents from this repo. Finally click on "Add key".

[Detailed explanation on hugmanrique.me blog post](https://hugmanrique.me/blog/deploying-playpen-with-gitlab-ci)

### Setting the GitLab variables

You will need to set the `GITLAB_HOST` variable on the `Dockerfile` to the main GitLab hostname you're using.

Next, set the repo name on the `RUN git clone` line to precache the `playpen-packages` repo on the produced image (to avoid huge deltas and possible build timeouts on first run).

## Building the image

First clone the repo on a machine that has an active [GitLab runner](https://docs.gitlab.com/runner/) instance and run:

```shell
cd image
git pull
```

Next, in order to build and tag the image run:

```shell
docker build -t playpen-runner .
```

**Note:** you might need to have `root` permissions to run the command above.

Once Docker is done, the GitLab runner will be able to directly use this image if you ran the command on the same machine where the GitLab instance is installed on.

You can additionally inspect the image contents by running:

```shell
docker run --rm -it --entrypoint=/bin/bash playpen-runner
```

### ~~Important security note about SSH keys~~

~~As you can see, this directory contains both a public and private SSH keys. These SSH keys give read-only access to the PlayPen packages repo stored in GitLab. If you're going to publish this repo anywhere else, please make sure to remove these files.~~

~~Ideally, we would want to have a better `git clone` system that wouldn't require any credentials and would whitelist any Docker container, but that would also open up other security issues.~~

_This repo previously contained the SSH keys but these were removed on public release_
