#!/bin/bash

# 🚀 Terraform Reset Script
# Полный пересоздание инфраструктуры

set -e  # выход при ошибке

echo "🛑 Уничтожаем текущую инфраструктуру..."
terraform destroy -auto-approve

echo "♻️  Пересоздаём инфраструктуру..."
terraform apply -auto-approve

echo "✅ Готово! Новая инфраструктура поднята."
