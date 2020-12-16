#!groovy

IMAGE_BASENAME = 'ynd-consult-ug/docker-ruby:'
RUBY_VERSIONS  = [
  '2.5.3',
  '2.6.2',
  '2.6.3',
  '2.6.5',
  '2.6.6'
]

ALPINE_VERSIONS = [
  '3.11',
  '3.12'
]

CENTOS_VERSIONS = [
  '7'
]

node('ynd') {
  withDockerRegistry(credentialsId: 'hub.docker.com') {
    ALPINE_VERSIONS.each{ os ->
      RUBY_VERSIONS.each { version ->
        IMAGE_NAME = "${IMAGE_BASENAME}${version}-alpine${os}"
        stage(IMAGE_NAME) {
          versionParts = version.tokenize('.')
          sh "docker build -t ${IMAGE_NAME} -f Dockerfile.alpine" +
          " --build-arg DISTRO_VERSION=${os}" +
          " --build-arg RUBY_VERSION=${version}" +
          " --build-arg RUBY_MAJOR=${versionParts[0]}.${versionParts[1]} ."
        }
      }
    }

    CENTOS_VERSIONS.each{ os ->
      RUBY_VERSIONS.each { version ->
        IMAGE_NAME = "${IMAGE_BASENAME}${version}-alpine${os}"
        stage(IMAGE_NAME) {
          sh "docker build -t ${IMAGE_NAME} -f Dockerfile.centos" +
          " --build-arg DISTRO_VERSION=${os}" +
          " --build-arg RUBY_VERSION=${version} ."
        }
      }
    }
  }

  stage('Cleanup') {
    cleanWs()
  }
}