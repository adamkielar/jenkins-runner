pipeline {
  agent {
    kubernetes {
      defaultContainer 'kaniko'
      yaml '''
kind: Pod
spec:
  containers:
  - name: kaniko
    image: gcr.io/kaniko-project/executor:v1.9.0-debug
    imagePullPolicy: Always
    command:
    - sleep
    args:
    - 99d
    envFrom:
      - secretRef:
          name: acr-sp
    volumeMounts:
      - name: docker-config
        mountPath: /kaniko/.docker/
  volumes:
    - name: docker-config
      configMap:
        name: docker-config

'''
    }
  }
  stages {
    stage('Kaniko Build and Push') {
      steps {
        sh '/kaniko/executor --dockerfile=${PWD}/Dockerfile -c ${PWD} --cache=true --destination=jenkinsacr7142.azurecr.io/jenkins-demo:v1.0.0'
      }
    }
    stage('Deploy Application') {
      agent {
    kubernetes {
      defaultContainer 'kubectl'
      yaml '''
  kind: Pod
  spec:
    containers:
    - name: kubectl
      image: quay.io/tfgco/kubectl
      imagePullPolicy: Always
      command:
      - sleep
      args:
      - 99d
'''
    }
  }
      steps {
        sh 'kubectl apply -f /home/jenkins/agent/workspace/jenkins-on-aks_master/pod.yaml'
      }
    }
  }
}
