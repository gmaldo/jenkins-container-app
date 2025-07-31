pipeline {
  agent any

  environment {
    // Variables para Terraform (si decides no usar .tfvars)
    TF_VAR_subscription_id = credentials('azuresubscription_id')
    TF_VAR_client_id       = 'b24fa600-ff3d-414a-9802-79047c858bce'
    TF_VAR_client_secret   = credentials('azureclient_secret')
    TF_VAR_tenant_id       = '8ee9d595-4f94-41e5-a20c-b29b4e64578b'

    // Para Azure CLI (az login)
    AZURE_CLIENT_ID        = 'b24fa600-ff3d-414a-9802-79047c858bce'
    AZURE_CLIENT_SECRET    = credentials('azureclient_secret')
    AZURE_TENANT_ID        = '8ee9d595-4f94-41e5-a20c-b29b4e64578b'
    
    ACR_NAME               = 'acrtfexample'
    IMAGE_NAME             = 'myapp'
    IMAGE_TAG              = 'latest'
    RESOURCE_GROUP         = 'rg-containerapp'
  }

  stages {
    stage('Debug Jenkins Secret') {
      steps {
        echo "AZURE_CLIENT_SECRET=${AZURE_CLIENT_SECRET.length()} chars"
      }
    }
    
    stage('Verificar Variables TF') {
      steps {
        sh '''
        echo "TF_VAR_subscription_id=$TF_VAR_subscription_id"
        echo "TF_VAR_client_id=$TF_VAR_client_id"
        echo "TF_VAR_tenant_id=$TF_VAR_tenant_id"
        '''
      }
    }
    
    stage('Terraform Init & ACR Deployment') {
      steps {
        dir('terraform/infra') {
          sh 'terraform init'
          sh 'terraform apply -auto-approve'
        }
      }
    }

    stage('Login to Azure & ACR') {
      steps {
        sh '''
        source /opt/azenv/bin/activate
        az login --service-principal -u $AZURE_CLIENT_ID -p $AZURE_CLIENT_SECRET --tenant $AZURE_TENANT_ID
        az acr login --name $ACR_NAME
        '''
      }
    }

    stage('Build and Push Docker Image') {
      steps {
        dir('docker') {
          sh '''
          source /opt/azenv/bin/activate
          ACR_LOGIN_SERVER=$(az acr show --name $ACR_NAME --query loginServer -o tsv)
          docker build -t $ACR_LOGIN_SERVER/$IMAGE_NAME:$IMAGE_TAG .
          docker push $ACR_LOGIN_SERVER/$IMAGE_NAME:$IMAGE_TAG
          '''
        }
      }
    }

    stage('Deploy Container App') {
      steps {
        dir('terraform/app') {
          sh 'terraform init'
          sh 'terraform apply -auto-approve'
        }
      }
    }
  }
}