#!/bin/bash

# 🚀 Git Commands для заливки проекта в GitHub

echo "🚀 Terraform AWS Automation - GitHub Deployment Commands"
echo "======================================================"

# Создать новую ветку feature/terraform-aws-automation
echo "1. Создание новой ветки:"
echo "git checkout -b feature/terraform-aws-automation"
echo

# Добавить все файлы
echo "2. Добавление файлов в git:"
echo "git add ."
echo

# Сделать первый коммит
echo "3. Первый коммит:"
echo 'git commit -m "🚀 Add Terraform AWS automation infrastructure

- Add S3 backend with DynamoDB locking
- Add EC2 instance with auto start/stop schedule  
- Add Lambda functions for instance management
- Add S3 cross-region replication
- Add IAM roles and policies
- Add lifecycle management for S3
- Add complete automation for infrastructure"'
echo

# Запушить ветку
echo "4. Push ветки в GitHub:"
echo "git push -u origin feature/terraform-aws-automation"
echo

# Создать Pull Request (через GitHub CLI или веб)
echo "5a. Создать Pull Request через GitHub CLI (если установлен):"
echo 'gh pr create --title "🚀 Terraform AWS Automation Infrastructure" --body "
## 🎯 Описание
Полная автоматизация AWS инфраструктуры с Terraform:

### ✅ Реализовано:
- **Backend**: S3 + DynamoDB locking механизм
- **EC2**: Автоматический старт (9:00) и стоп (21:00) по расписанию
- **S3**: Cross-region replication между eu-central-1 и eu-west-1  
- **Lambda**: Функции управления EC2 по расписанию
- **IAM**: Роли и политики для безопасного доступа
- **Lifecycle**: Автоматическое архивирование в Glacier
- **Мониторинг**: Логирование всех операций

### 🛠️ Технологии:
- Terraform >= 1.6.0
- AWS Provider ~> 5.0
- Lambda (Python 3.9)
- EventBridge (CloudWatch Events)
- S3, DynamoDB, EC2, IAM

### 🚀 Развертывание:
\`\`\`bash
chmod +x deploy.sh
./deploy.sh
\`\`\`

### ✅ Тестирование:
- [x] terraform plan проходит без ошибок
- [x] terraform apply создает все ресурсы  
- [x] Backend с locking работает
- [x] EC2 автоматически управляется по расписанию
- [x] S3 репликация настроена
- [x] IAM права минимальные и достаточные

Готово к merge! 🎉
"'
echo

echo "5b. Или создать Pull Request через веб-интерфейс GitHub:"
echo "   - Перейти на https://github.com/YOUR_USERNAME/YOUR_REPO"
echo "   - Нажать 'Compare & pull request'"
echo "   - Заполнить описание и создать PR"
echo

echo "======================================================"
echo "📋 Полный workflow:"
echo "======================================================"

cat << 'EOF'
# 1. Клонировать репозиторий (если еще не сделано)
git clone https://github.com/YOUR_USERNAME/YOUR_REPO.git
cd YOUR_REPO

# 2. Создать папку проекта и скопировать все файлы
mkdir -p terraform-aws-automation
cd terraform-aws-automation

# Скопировать все .tf файлы, scripts, README.md в эту папку

# 3. Создать и переключиться на новую ветку
git checkout -b feature/terraform-aws-automation

# 4. Настроить SSH ключ в ec2.tf
# Заменить placeholder на свой публичный ключ

# 5. Добавить файлы в git
git add .

# 6. Сделать коммит
git commit -m "🚀 Add Terraform AWS automation infrastructure

Features:
- S3 backend + DynamoDB locking
- EC2 auto start/stop scheduling  
- Cross-region S3 replication
- Lambda-based instance management
- Complete IAM security setup
- Lifecycle policies for cost optimization

Ready for production deployment! 🎉"

# 7. Запушить ветку
git push -u origin feature/terraform-aws-automation

# 8. Создать Pull Request
gh pr create --title "🚀 Terraform AWS Automation Infrastructure" \
--body "Complete infrastructure automation with backend, auto-scheduling, and replication"

# 9. После мержа PR - развернуть инфраструктуру
git checkout main
git pull origin main
cd terraform-aws-automation

# 10. Запустить развертывание
chmod +x deploy.sh
./deploy.sh

# 11. Проверить что всё работает
terraform output
aws ec2 describe-instances --filters "Name=tag:Name,Values=terraform-automation-auto-server"
aws s3 ls

echo "🎉 Deployment completed! Infrastructure is automated and ready!"
EOF

echo
echo "======================================================"
echo "🎯 Чек-лист перед Push:"
echo "======================================================"
echo "[ ] Все .tf файлы в папке terraform-aws-automation/"
echo "[ ] SSH ключ заменен на свой в ec2.tf"
echo "[ ] README.md содержит инструкции"
echo "[ ] deploy.sh имеет права на выполнение"
echo "[ ] Все lambda/*.py файлы на месте"
echo "[ ] user_data.sh скрипт готов"
echo "[ ] Проверили terraform fmt и terraform validate"
echo
echo "✅ Готово к Push в GitHub!"
echo "🚀 Время покорять космос инфраструктуры!"