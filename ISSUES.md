Este arquivo tem a intenção de descrever os erros enfrentados durante o processo e quais as soluções encontradas:


##### ISSUE 001: A EC2 perde conexão quando alteramos o outbound rule para o security group do Load Balancer

Solução: O load balancer é um gerenciador de requisições de entrada e não de saída, sendo assim a ec2 nunca teria acesso a internet, pra isso teria que ser usado um NAT em caso de ec2 privada.

