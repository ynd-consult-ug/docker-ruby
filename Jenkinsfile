#!groovy

IMAGE_BASENAME = 'yndconsult/docker-ruby:'
RUBY_VERSIONS  = [
  '2.5.3': '622ffa051470e967f3e51cc6347783e93d9b09a4557d4f5a78efb87b959f87a3',
  '2.6.2': '91fcde77eea8e6206d775a48ac58450afe4883af1a42e5b358320beb33a445fa',
  '2.6.3': '11a83f85c03d3f0fc9b8a9b6cad1b2674f26c5aaa43ba858d4b0fcc2b54171e1',
  '2.6.5': '9455170dd264f69bd92ab0f4f30e5bdfc1ecafe32568114f1588a3850ca6e5fd',
  '2.6.6': '0899af033c477c0eafeafd59925ce1165a651af6690c5812931d821b4a048d14',
  '2.7.2': 'c6b8597e5414f2b01a7cb25095319f2b0e780c95a98fee1ccf1ef022acf93dcc',
  '3.0.0': '68bfaeef027b6ccd0032504a68ae69721a70e97d921ff328c0c8836c798f6cb1'
]

ALPINE_VERSIONS = [
  '3.11',
  '3.12',
  '3.13'
]

CENTOS_VERSIONS = [
  '7'
]

node('ynd') {
  stage('Fetch code') {
    GIT = utils.checkoutRepository('git@github.com:ynd-consult-ug/docker-ruby.git')
  }

  withDockerRegistry(credentialsId: 'hub.docker.com') {
    ALPINE_VERSIONS.each{ os ->
      RUBY_VERSIONS.each { version, sha ->
        IMAGE_NAME = "${IMAGE_BASENAME}${version}-alpine${os}"
        stage(IMAGE_NAME) {
          versionParts = version.tokenize('.')
          sh "docker build -t ${IMAGE_NAME} -f Dockerfile.alpine" +
          " --build-arg DISTRO_VERSION=${os}" +
          " --build-arg RUBY_SHA=${sha}" +
          " --build-arg RUBY_VERSION=${version} ."
        }
        stage("Push ${IMAGE_NAME}") {
          sh "docker push ${IMAGE_NAME}"
        }
      }
    }

    CENTOS_VERSIONS.each{ os ->
      RUBY_VERSIONS.each { version, sha ->
        IMAGE_NAME = "${IMAGE_BASENAME}${version}-centos${os}"
        stage(IMAGE_NAME) {
          sh "docker build -t ${IMAGE_NAME} -f Dockerfile.centos" +
          " --build-arg DISTRO_VERSION=${os}" +
          " --build-arg RUBY_SHA=${sha}" +
          " --build-arg RUBY_VERSION=${version} ."
        }
        stage("Push ${IMAGE_NAME}") {
          sh "docker push ${IMAGE_NAME}"
        }
      }
    }
  }

  stage('Cleanup') {
    cleanWs()
  }
}
