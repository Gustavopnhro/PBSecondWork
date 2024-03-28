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
Durante esse processo eu vou criar os security groups que serão usados:

+ lb-sg-001 - Security Group para o Load Balancer:
  
  |Protocol| Type | Range | Source-type | Source     |
  |--------|------|-------|-------------|------------|
  |TCP     |HTTP  |80     |Anywhere     |0.0.0.0/0   |

<div align="center">
  <img src="./src/img/steps/sg-002.png" alt="Security Group para o Load Balancer" width="850px">
   <p><em>Security Group para o Load Balancer</em></p>
</div>


+  ec2-sg-001 - Security Group para as instâncias EC2:

  |Protocol| Type | Range | Source-type | Source     |
  |--------|------|-------|-------------|------------|
  |TCP     |SSH   |22     |My ip        |172.0.0.0/32|
  |TCP     |HTTP  |80     |Anywhere     |lb-sg-001   |

<div align="center">
  <img src="./src/img/steps/sg-001.png" alt="Security Group para a EC2" width="850px">
   <p><em>Security Group para a EC2</em></p>
</div>

+ rds-sg-001 - Security Group para o serviço de banco de dados com RDS:

  |Protocol| Type   | Range | Source-type | Source     |
  |--------|--------|-------|-------------|------------|
  |TCP     |MYSQL   |3306   |Anywhere     |0.0.0.0/0   |

<div align="center">
  <img src="./src/img/steps/sg-003.png" alt="Security Group para o RDS" width="850px">
   <p><em>Security Group para o RDS</em></p>
</div>

+ efs-sg-001 - Security Group para o serviço de EFS:
 
  |Protocol| Type | Range | Source-type | Source     |
  |--------|------|-------|-------------|------------|
  |TCP     |NFS   |2049   |Anywhere     |lb-sg-001   |

<div align="center">
  <img src="./src/img/steps/sg-004.PNG" alt="Security Group para o EFS" width="850px">
   <p><em>Security Group para o EFS</em></p>
</div>

### Elastic File System

Em seguida vou criar o Elastic File System (EFS) que irá armazenar os arquivos estáticos do wordpress direcionando seus endpoints

Na tela de EFS vou configurar o nome como "wordpress" e a VPC que será usada no processo, com o EFS criado vamos configurar na aba de network o security group para o efs-sg-001 criado anteriormente.

<div align="center">
  <img src="./src/img/steps/efs-001.png" width="850px">
</div>


<div align="center">
  <img src="./src/img/steps/efs-002.png" width="850px">
   <p><em>Aba "Network" do EFS</em></p>
</div>

### Load Balancer (Classic)

Nessa seção eu vou criar o Load Balancer Classic que será utilizado para acesso:

<div align="center">
  <img src="./src/img/steps/lb-001.png" width="850px">
   <p><em>Classic Load Balancer</em></p>
</div>

O nome do Classic Load Balancer será "classic-load-balance-001" e escolher as duas subnets que as requisições serão balanceadas
<div align="center">
  <img src="./src/img/steps/lb-002.png" width="850px">
   <p><em>Classic Load Balancer</em></p>
</div>

No securtiy group vou adicionar o "lb-sg-001" criado anteriormente, e no "/wp-admin/install.php", a razão para optar por esse health-check é pela característica da atividade, como essa é uma rota que existe antes e depois do wordpress estar instalado na necessidade de apagar toda a estrutura e subir ela novamente vamos ter ela acessível e saudável para o health check antes mesmo de instalarmos o wordpress.

<div align="center">
  <img src="./src/img/steps/lb-003.png" width="850px">
   <p><em>Classic Load Balancer</em></p>
</div>


### 📚 Referências 📚