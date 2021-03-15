#!groovy
properties([
  buildDiscarder(
    logRotator(numToKeepStr: '5')
  ),
  disableResume(),
  pipelineTriggers([
    githubPush(),
  ])
])

IMAGE_BASENAME = 'yndconsult/docker-ruby:'
RUBY_VERSIONS  = [
  '2.5.3': '1cc9d0359a8ea35fc6111ec830d12e60168f3b9b305a3c2578357d360fcf306f',
  '2.6.2': '91fcde77eea8e6206d775a48ac58450afe4883af1a42e5b358320beb33a445fa',
  '2.6.3': '11a83f85c03d3f0fc9b8a9b6cad1b2674f26c5aaa43ba858d4b0fcc2b54171e1',
  '2.6.5': 'd5d6da717fd48524596f9b78ac5a2eeb9691753da5c06923a6c31190abe01a62',
  '2.6.6': '5db187882b7ac34016cd48d7032e197f07e4968f406b0690e20193b9b424841f',
  '2.7.2': '1b95ab193cc8f5b5e59d2686cb3d5dcf1ddf2a86cb6950e0b4bdaae5040ec0d6',
  '3.0.0': '68bfaeef027b6ccd0032504a68ae69721a70e97d921ff328c0c8836c798f6cb1'
]

node('ynd') {
  stage('Fetch code') {
    GIT = utils.checkoutRepository('git@github.com:ynd-consult-ug/docker-ruby.git')
  }

  try {
    stage('Hadolint checks') {
      security.hadolintChecks('Dockerfile.alpine')
    }
  } catch(err) {
      stage('Send slack notification') {
        slackSend channel: '#ops-notifications', message: "Build failed: ${env.JOB_NAME}. Hadolint checks failed. See logs for more information. <${env.BUILD_URL}>", color: 'danger'
      }
      error "Hadolint checks failed. ${err}" 
  }

  if(env.BRANCH_NAME == 'master') {
    stage('Fetch alpine') {
      sh 'docker pull alpine:3.13'
    }

    withDockerRegistry(credentialsId: 'hub.docker.com') {
      RUBY_VERSIONS.each { version, sha ->
        IMAGE_NAME = "${IMAGE_BASENAME}${version}"
        stage(IMAGE_NAME) {
          versionParts = version.tokenize('.')
          sh "docker build -t ${IMAGE_NAME} -f Dockerfile.alpine" +
          " --build-arg RUBY_DOWNLOAD_SHA256=${sha}" +
          " --build-arg RUBY_VERSION=${version} ."
        }
        stage("Push ${IMAGE_NAME}") {
          sh "docker push ${IMAGE_NAME}"
        }
      }
    }

    stage('Cleanup') {
      cleanWs()
    }
  }
}
