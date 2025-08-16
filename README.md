# 🚀 Despliegue de Azure Container App con Terraform + Jenkins + ACR

Este repositorio contiene una solución completa para desplegar una Azure Container App utilizando:

- **Terraform** para la infraestructura
- **Jenkins** como orquestador CI/CD
- **Azure Container Registry (ACR)** para almacenamiento de imágenes Docker

---

## 📁 Estructura del repositorio

```
.
├── Jenkinsfile                    # Pipeline CI/CD para Jenkins
├── terraform/
│   ├── infra/                     # Crea RG, ACR, Log Analytics y Container App Environment
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── app/                       # Despliega Container App cuando la imagen ya está en ACR
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
├── docker/
│   ├── Dockerfile                 # Imagen basada en Nginx con contenido HTML simple
│   └── app/
│       └── index.html
└── .github/
    └── workflows/                # (opcional) CI con GitHub Actions si se desea
```

---

## 🔁 Flujo de despliegue con Jenkins

### 🏗️ Infraestructura Desplegada

#### **Fase 1: Infraestructura Base (`terraform/infra/`)**

**Azure Container Registry (ACR)**:

- Registro privado para almacenar imágenes Docker
- Nombre único global: `acrtfgmaldo.azurecr.io`

**Log Analytics Workspace**:

- Centraliza logs y métricas de la Container App

**Container App Environment**:

- Entorno compartido donde viven las Container Apps
- Maneja networking y scaling automático

#### **Fase 2: Aplicación (`terraform/app/`)**

**Identidad Managed**:

- User-assigned identity para acceso seguro al ACR
- Rol `AcrPull` asignado automáticamente
- Sin credenciales hardcodeadas en la aplicación

**Container App**:

- Contenedor con 0.5 CPU y 1GB RAM
- Ingress público habilitado en puerto 80
- Auto-scaling basado en demanda
- URL pública generada automáticamente

### 🐳 Proceso de Creación de Imagen Docker

**Dockerfile optimizado**:

```dockerfile
FROM --platform=linux/amd64 nginx:alpine
COPY app/index.html /usr/share/nginx/html/index.html
```

lo de amd64 lo pongo para forzar porque mi pc es arm64 y azure no es compatible con contenedores arm64

**Características**:

- **Base**: Nginx Alpine (ligera, ~5MB)
- **Platform**: linux/amd64 para compatibilidad con Azure
- **Content**: HTML personalizado servido por Nginx
- **Puerto**: 80 (estándar HTTP)

### 📤 Subida a Azure Container Registry

**Proceso automatizado en Jenkins**:

```bash
# 1. Autenticación con Service Principal
az login --service-principal -u $AZURE_CLIENT_ID -p $AZURE_CLIENT_SECRET --tenant $AZURE_TENANT_ID

# 2. Login específico en ACR
az acr login --name $ACR_NAME

# 3. Build con tag correcto del ACR
ACR_LOGIN_SERVER=$(az acr show --name $ACR_NAME --query loginServer -o tsv)
docker build -t $ACR_LOGIN_SERVER/$IMAGE_NAME:$IMAGE_TAG .

# 4. Push al registro privado
docker push $ACR_LOGIN_SERVER/$IMAGE_NAME:$IMAGE_TAG
```

**Resultado**: Imagen disponible en `acrtfgmaldo.azurecr.io/myapp:latest`

### 🚀 Despliegue de Container App


**Proceso automático**:

1. Terraform crea la Container App con referencia a la imagen en ACR
2. Azure detecta la configuración y descarga la imagen usando la identidad managed
3. Crea el contenedor con los recursos especificados (0.5 CPU, 1GB RAM)
4. Configura ingress público y asigna URL automáticamente
5. Habilita auto-scaling y health checks

### 📋 Orden de Ejecución del Pipeline

**Stage 1-2: Verificación**

- Debug de credenciales Jenkins
- Validación de variables Terraform

**Stage 3: Infraestructura Base**

```groovy
dir('terraform/infra') {
  sh 'terraform init'
  sh 'terraform apply -auto-approve'
}
```

- Crea ACR, Log Analytics y Container App Environment

**Stage 4: Autenticación**

```groovy
az login --service-principal -u $AZURE_CLIENT_ID -p $AZURE_CLIENT_SECRET --tenant $AZURE_TENANT_ID
az acr login --name $ACR_NAME
```

- Login con Service Principal en Azure
- Autenticación específica en ACR para push

**Stage 5: Build y Push**

```groovy
dir('docker') {
  ACR_LOGIN_SERVER=$(az acr show --name $ACR_NAME --query loginServer -o tsv)
  docker build -t $ACR_LOGIN_SERVER/$IMAGE_NAME:$IMAGE_TAG .
  docker push $ACR_LOGIN_SERVER/$IMAGE_NAME:$IMAGE_TAG
}
```

- Build de imagen Docker con tag del ACR
- Push al registro privado
- **Importante**: La imagen debe estar disponible antes del despliegue

**Stage 6: Despliegue Final**

```groovy
dir('terraform/app') {
  sh 'terraform init'
  sh 'terraform apply -auto-approve'
}
```

- Crea Container App que referencia la imagen en ACR
- Configura identidad managed y permisos
- Habilita ingress público

### 🎯 Ventajas de esta Arquitectura

- **Separación de responsabilidades**: Infraestructura vs aplicación
- **Reutilización**: ACR y environment se crean una vez, se usan muchas veces
- **Seguridad**: Identidades managed, sin credenciales hardcodeadas
- **Escalabilidad**: Auto-scaling nativo de Container Apps
- **Observabilidad**: Logs centralizados en Log Analytics
- **Eficiencia**: Solo se recrea la aplicación en cambios de código

---

## 🧪 Requisitos

- Azure CLI
- Terraform
- Docker
- Jenkins con Docker disponible
- Credenciales de Azure como secretos en Jenkins

---

## ✅ Pasos para usar

### 1. Crear credenciales en Jenkins

Agrega los siguientes secretos:

- `azure-subscription-id`
- `azure-client-id`
- `azure-client-secret`
- `azure-tenant-id`

### 2. Ejecutar el pipeline

Haz clic en **Build Now** en Jenkins y observa el despliegue paso a paso.

---

## 🌐 Resultado final

La Container App será accesible desde una URL pública como:

```
https://<containerapp-name>.<region>.azurecontainerapps.io/
```

---

## 📄 Licencia

MIT
