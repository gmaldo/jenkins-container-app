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

![CI/CD Flow](ci_cd_pipeline_flow.png)

1. **`terraform/infra/`**: Se crea el Resource Group, ACR y entorno de Container App.
2. **Docker**: Se construye y sube la imagen al ACR.
3. **`terraform/app/`**: Se despliega la Container App referenciando la imagen en ACR.

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
