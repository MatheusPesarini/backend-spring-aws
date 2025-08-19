# Projeto Pessoal – Deploy de Aplicação Web na AWS

Backend Spring Boot com PostgreSQL, S3, IAM, EC2/RDS e monitoramento básico no CloudWatch, aplicando práticas do Well-Architected Framework.

## Stack
- Java 17, Spring Boot 3 (Web, Data JPA, Validation, Actuator)
- PostgreSQL (local via Docker e na AWS via RDS)
- AWS SDK v2 (S3, STS), Micrometer CloudWatch 2
- Terraform (VPC, EC2, RDS, S3, IAM, CloudWatch)
- Dockerfile e docker-compose

## Endpoints
- Notes CRUD mínimo:
  - GET /api/notes
  - GET /api/notes/{id}
  - POST /api/notes {title, content}
  - DELETE /api/notes/{id}
- Storage (S3 pré‑assinado):
  - POST /api/storage/presign/put?key=...&contentType=...
  - GET  /api/storage/presign/get?key=...
- Actuator: /actuator/health, /actuator/info, /actuator/metrics

## Execução local (PostgreSQL via Docker)
1) Build e testes:
```bash
mvn test
mvn -DskipTests package
```
2) Subir stack local (app + Postgres):
```bash
docker compose up -d --build
```
3) Testes rápidos:
```bash
curl http://localhost:8080/actuator/health
curl -X POST http://localhost:8080/api/notes \
  -H "Content-Type: application/json" \
  -d '{"title":"Primeira nota","content":"Olá AWS"}'
```

Observações:
- Variáveis (application.yml) podem ser configuradas via env: DB_URL, DB_USERNAME, DB_PASSWORD, AWS_REGION, S3_BUCKET, CLOUDWATCH_ENABLED (desativado por padrão local).

## Infra AWS com Terraform
Pré‑requisitos: AWS CLI autenticado; Terraform >= 1.6; definir senha do banco (db_password).

1) Inicializar e revisar o plano:
```bash
cd infra/terraform
terraform init
terraform plan -var "db_password=SUASENHA" -out tfplan
```
2) Aplicar:
```bash
terraform apply tfplan
```
Outputs úteis: IP/DNS do EC2, endpoint do RDS, nomes dos buckets S3 e Log Group.

3) Publicar artefato (JAR) no bucket de artefatos:
```bash
cd ../../
mvn -DskipTests package
aws s3 cp target/backend-spring-aws-0.0.1-SNAPSHOT.jar \
  s3://$(terraform -chdir=infra/terraform output -raw s3_artifact_bucket)/app.jar
```

4) Início automático no EC2:
- O user_data baixa o JAR do bucket de artefatos e inicia o serviço systemd (app.service).
- Variáveis de ambiente de runtime (DB_URL, credenciais do RDS, S3_BUCKET, etc.) são injetadas pelo user_data.
- A porta da aplicação é 8080 (liberada no SG). Acesse: http://EC2_PUBLIC_DNS:8080/actuator/health

## IAM e permissões
- EC2 Instance Profile com permissões mínimas para:
  - Ler artefatos no bucket de artefatos e RW no bucket da aplicação.
  - PutMetricData no CloudWatch (namespace fixo BackendSpringAWS).
  - Logs no CloudWatch Logs (Log Group criado por Terraform).

## Monitoramento (CloudWatch)
- Micrometer envia métricas para o namespace BackendSpringAWS (habilitado no EC2 via env CLOUDWATCH_ENABLED=true).
- CloudWatch Agent (opcional) coleta logs em /var/log/app/app.log para o Log Group provisionado.

## Well-Architected (resumo aplicado)
- Segurança: SG específico por função; RDS privado; S3 com bloqueio público e SSE (AES256); princípio do menor privilégio no IAM; variáveis sensíveis fora do código.
- Confiabilidade: RDS gerenciado com backups; app em systemd com restart; logs centralizados no CloudWatch.
- Otimização de custos: instâncias pequenas (t3.micro/db.t4g.micro); buckets com versionamento; retenção de logs reduzida (7 dias). Ajuste conforme demanda.

## Troubleshooting de deploy
- JAR não inicia no EC2:
  - Verifique se o JAR foi copiado para o bucket de artefatos no caminho app.jar.
  - Logs no EC2: `sudo journalctl -u app -f` e `/var/log/app/app.log`.
- Sem acesso ao endpoint:
  - Cheque SG de entrada na porta 8080 e o IP público do EC2.
- Erros de DB:
  - Confirme o endpoint do RDS no output e credenciais; o SG do RDS permite tráfego do SG do app.
- Métricas/Logs não aparecem:
  - Verifique permissões IAM e se CLOUDWATCH_ENABLED=true no EC2; confira CloudWatch Agent status.

## Limpeza
```bash
terraform -chdir=infra/terraform destroy
```

## Próximos passos (opcional)
- ALB + Auto Scaling Group (alta disponibilidade). 
- Secrets Manager/SSM Parameter Store para segredos do DB. 
- Backup/retention policies mais robustas e alarmes CloudWatch.

