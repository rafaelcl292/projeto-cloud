# projeto-cloud

## Diagrama da infraestrutura

![Diagrama da infraestrutura](diagrama_redes.svg)

## Criação da infraestrutura na AWS

É necessário criar um bucket no S3 para armazenar o estado do terraform, com o nome especificado no arquivo `provider.tf`.

Em sequida clone o repositório, execute os comandos abaixo para criar a infraestrutura na AWS.

Certifique-se de ter o terraform instalado e configurado com as credenciais da AWS.

```
terraform init
```

```
terraform apply --auto-approve
```

Para acessar a aplicação basta entrar no link exibido no output, ele se refere ao Load Balancer.
