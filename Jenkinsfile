#!/usr/bin/env groovy

pipeline {
    agent any
    environment {  // set env-variables so aws-provider can grab those variables and connect to aws
            // variables are the same as AWS-CLI // we already created 'jenkins_aws_access_key_id' from jenkins credentials
        AWS_ACCESS_KEY_ID = credentials('jenkins_aws_access_key_id') 
            // variables are the same as AWS-CLI // we already created 'jenkins_aws_secret_access_key' from jenkins credentials
        AWS_SECRET_ACCESS_KEY = credentials('jenkins_aws_secret_access_key')
               
    }


        stage('build and push  docker image') {  
            steps {			
                 script {                    
                    echo "------------------------------------------------  build-image and push to dockerhub"
                    withCredentials([usernamePassword(credentialsId: 'dockerhub_pass', usernameVariable: 'USER', passwordVariable: 'PASS')]) { 
                        sh "docker build -t the6thplanet/ant-international-group-app:1 ./src/app_v1.py"    // build image from Dockerfile
                        sh 'echo $PASS | docker login -u $USER --password-stdin'
                        sleep 2
                        sh "docker push the6thplanet/ant-international-group-app:1"    // push to dockerhub
                    }
                }               
            }
        }


        stage('Jenkins-Terraform') {
            steps {
                script {
                    echo "---------------------------------------------- Jenkins-Terraform"
                    dir('terraform') {
                        sh "terraform init"   
                        sh "terraform apply --auto-approve -target=vpc.tf && terraform apply --auto-approve -target=eks-cluster.tf"

                    }
                }
            }
        }


        stage('jenkins-Deployment') {
            steps {
                script {
                    echo "---------------------------------------------- Jenkins-Deployment"
                    sh "kubectl apply -f deploy.yaml"
                   
                    }
                }
            }
        }


    }
}
