'use strict';

const fs = require('fs');
const path = require('path');
const exec = require('child_process').exec;
const maven = require('maven-deploy');

const buildDir = path.resolve(__dirname, 'dist');

const config = {
  groupId: 'io.playpen',
  artifactId: 'PlayPen',
  version: '1.0',
  buildDir,
  finalName: '{name}',
  type: 'jar',
  generatePom: false,
  pomFile: 'pom.xml',
  repositories: [
    {
      id: 'REDACTED-release',
      url: 'https://REDACTED/libs-release'
    }
  ]
};

const releaseDeployRepo = 'REDACTED-release';

const mavenPackage = () => {
  maven.config(config);

  // No need to package, deploy directly
  if (process.argv.indexOf('--skipPackage') >= 0) {
    return deploy();
  }

  console.log('Packaging...');
  exec(`mvn -f ${buildDir} package`, deploy);
};

const deploy = () => {
  const targetPath = path.join(buildDir, 'target');
  const files = fs.readdirSync(targetPath);

  // PlayPen-1.0.jar seems to be the last modified file by Maven
  const artifact = files
    .filter(
      file =>
        file.indexOf('.jar') >= 0 &&
        file.indexOf('original') === -1 &&
        file.indexOf('shaded') === -1
    )
    .reduce(
      (prev, file) => {
        const fullPath = path.join(targetPath, file);
        const time = fs.statSync(fullPath).mtime;

        if (time < prev[0]) {
          return prev;
        }

        return [time, fullPath];
      },
      [0, false]
    )[1];

  if (!artifact) {
    console.error(`Couldn't find any artifact in ${targetPath}`);
    return;
  }

  // This is a release, not a snapshot
  maven.deploy(releaseDeployRepo, artifact, false);
};

mavenPackage();
