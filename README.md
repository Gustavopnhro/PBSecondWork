# SEGUNDA ATIVIDADE PB COMPASS


<div align="center">
  <img src="./src/img/logo_uol_compass.png" width="340px">
</div>

## Descrição

A atividade consiste na instalação do "docker" ou "containerd" no host Ec2, em seguida efetuar o deploy de uma aplicação Wordpress dispondo de um RDS utilizando o Mysql, efetuar a configuração do serviço EFS (Elastic File System) para os estáticos do container da aplicação Wordpress e configurar o serviço de Load Balancer para a aplicação.

Observações:
- Não utilizar ip público para saída dos serviços Wordpress;
- Saída do tráfego de internet para o Load Balancer;
- Pastas públicas e estáticos do Wordpress armazenadas no EFS;
- Utilizar Dockerfile ou docker-compose;
- Necessário mostrar a aplicação Wordpress funcionando (tela de login);
- Aplicação exposta na porta 80 ou 8080;
- Utilizar repositório Git para versionamento;
- Criar documentação.

## Requisitos 

- Instalação e configuração do DOCKER ou CONTAINERD no host EC2;

Obs: Ponto adicional para o trabalho 
utilizar a instalação via script de 
Start Instance (user_data.sh)

- Efetuar Deploy de uma aplicação Wordpress com: container de aplicação RDS database Mysql;

- Configuração da utilização do serviço EFS AWS para estáticos do container de aplicação Wordpress;

- Configuração do serviço de Load Balancer AWS para a aplicação Wordpress.

Pontos de atenção:
- Não utilizar ip público para saída do serviços WP (Evitem publicar o serviço WP via IP Público);
- Sugestão para o tráfego de internet sair pelo LB  (Load Balancer Classic) o pastas públicas e estáticos  do wordpress sugestão de utilizar o EFS (Elastic File Sistem);
- Fica a critério de cada integrante usar Dockerfile  ou Dockercompose;

- Necessário demonstrar a aplicação wordpress  funcionando (tela de login)
- Aplicação Wordpress precisa estar rodando na porta 80 ou 8080;
- Utilizar repositório git para versionamento;
- Criar documentação.


## Criação Manual

### 🔒 Security Groups 🔑
Criar um Security Group específico para cada recurso:

+  Grupo de Segurança para as EC2 deve conter as seguintes Inbound Rules:

  |Protocol| Type | Range | Source-type | Source     |
  |--------|------|-------|-------------|------------|
  |TCP     |SSH   |22     |Custom       |172.0.0.0/32|
  |TCP     |HTTP  |80     |Anywhere     |0.0.0.0/0   |

<div align="center">
  <img src="./src/img/steps/sg-001.png" alt="Security Group para a EC2" width="850px">
   <p><em>Security Group para a EC2</em></p>
</div>

+  Grupo de Segurança para o Load Balancer deve conter as seguintes Inbound Rules:

  |Protocol| Type | Range | Source-type | Source     |
  |--------|------|-------|-------------|------------|
  |TCP     |HTTP  |80     |Anywhere     |0.0.0.0/0   |

<div align="center">
  <img src="./src/img/steps/sg-002.png" alt="Security Group para a EC2" width="850px">
   <p><em>Security Group para o Load Balancer</em></p>
</div>



### 📚 Referências 📚