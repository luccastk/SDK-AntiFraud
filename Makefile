# SDK AntiFraud - Makefile para Desenvolvimento

.PHONY: help install build start stop clean test lint format

# Cores para output
BLUE := \033[0;34m
GREEN := \033[0;32m
YELLOW := \033[1;33m
RED := \033[0;31m
NC := \033[0m # No Color

# Variáveis
SDK_DIR := sdk-antifraude
KOTLIN_DIR := kotlin-api
ECOMMERCE_DIR := ecommerce-app

help: ## Mostra esta ajuda
	@echo "$(BLUE)SDK AntiFraud - Comandos Disponíveis$(NC)"
	@echo "=================================="
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "$(GREEN)%-20s$(NC) %s\n", $$1, $$2}'

install: ## Instala todas as dependências
	@echo "$(BLUE)Instalando dependências...$(NC)"
	@cd $(SDK_DIR) && npm install
	@cd $(ECOMMERCE_DIR) && npm install
	@chmod +x $(KOTLIN_DIR)/gradlew
	@echo "$(GREEN)Dependências instaladas!$(NC)"

build: ## Compila o SDK
	@echo "$(BLUE)Compilando SDK...$(NC)"
	@cd $(SDK_DIR) && npm run build
	@echo "$(GREEN)SDK compilado!$(NC)"

build-kotlin: ## Compila o backend Kotlin
	@echo "$(BLUE)Compilando backend Kotlin...$(NC)"
	@cd $(KOTLIN_DIR) && ./gradlew build
	@echo "$(GREEN)Backend Kotlin compilado!$(NC)"

start-backend: ## Inicia o backend Kotlin
	@echo "$(BLUE)Iniciando backend Kotlin...$(NC)"
	@cd $(KOTLIN_DIR) && ./gradlew bootRun

start-frontend: ## Inicia a aplicação Node.js
	@echo "$(BLUE)Iniciando aplicação Node.js...$(NC)"
	@cd $(ECOMMERCE_DIR) && npm start

start: ## Inicia todos os serviços
	@echo "$(BLUE)Iniciando todos os serviços...$(NC)"
	@make -j2 start-backend start-frontend

start-dev: ## Inicia ambiente de desenvolvimento completo
	@echo "$(BLUE)Iniciando ambiente de desenvolvimento...$(NC)"
	@./start-dev.sh

stop: ## Para todos os serviços
	@echo "$(YELLOW)Parando serviços...$(NC)"
	@pkill -f "gradlew bootRun" || true
	@pkill -f "npm start" || true
	@lsof -ti :3000 | xargs kill -9 2>/dev/null || true
	@lsof -ti :8080 | xargs kill -9 2>/dev/null || true
	@echo "$(GREEN)Serviços parados!$(NC)"

clean: ## Limpa arquivos temporários
	@echo "$(BLUE)Limpando arquivos temporários...$(NC)"
	@cd $(SDK_DIR) && npm run clean
	@cd $(KOTLIN_DIR) && ./gradlew clean
	@rm -f *.log
	@rm -f .pids
	@echo "$(GREEN)Limpeza concluída!$(NC)"

test: ## Executa testes
	@echo "$(BLUE)Executando testes...$(NC)"
	@cd $(SDK_DIR) && npm test
	@cd $(KOTLIN_DIR) && ./gradlew test
	@echo "$(GREEN)Testes concluídos!$(NC)"

lint: ## Executa linting
	@echo "$(BLUE)Executando linting...$(NC)"
	@cd $(SDK_DIR) && npm run lint || echo "$(YELLOW)Linting não configurado$(NC)"
	@echo "$(GREEN)Linting concluído!$(NC)"

format: ## Formata código
	@echo "$(BLUE)Formatando código...$(NC)"
	@cd $(SDK_DIR) && npm run format || echo "$(YELLOW)Format não configurado$(NC)"
	@echo "$(GREEN)Formatação concluída!$(NC)"

status: ## Verifica status dos serviços
	@echo "$(BLUE)Verificando status dos serviços...$(NC)"
	@if lsof -i :8080 >/dev/null 2>&1; then \
		echo "$(GREEN)✓ Backend Kotlin está rodando na porta 8080$(NC)"; \
	else \
		echo "$(RED)✗ Backend Kotlin não está rodando$(NC)"; \
	fi
	@if lsof -i :3000 >/dev/null 2>&1; then \
		echo "$(GREEN)✓ Aplicação Node.js está rodando na porta 3000$(NC)"; \
	else \
		echo "$(RED)✗ Aplicação Node.js não está rodando$(NC)"; \
	fi

logs: ## Mostra logs dos serviços
	@echo "$(BLUE)Logs dos serviços:$(NC)"
	@echo "$(YELLOW)Backend Kotlin:$(NC)"
	@tail -f kotlin-api.log 2>/dev/null || echo "Arquivo de log não encontrado"
	@echo "$(YELLOW)Aplicação Node.js:$(NC)"
	@tail -f ecommerce-app.log 2>/dev/null || echo "Arquivo de log não encontrado"

dev: install build start-dev ## Setup completo de desenvolvimento

quick-start: build start ## Início rápido (assume dependências instaladas)

# Comandos específicos para desenvolvimento
watch-sdk: ## Observa mudanças no SDK e recompila
	@echo "$(BLUE)Observando mudanças no SDK...$(NC)"
	@cd $(SDK_DIR) && npm run dev

watch-kotlin: ## Observa mudanças no Kotlin e recompila
	@echo "$(BLUE)Observando mudanças no Kotlin...$(NC)"
	@cd $(KOTLIN_DIR) && ./gradlew bootRun --continuous

# Comandos de utilidade
ports: ## Mostra portas em uso
	@echo "$(BLUE)Portas em uso:$(NC)"
	@lsof -i :3000,8080 || echo "Nenhuma porta em uso"

kill-ports: ## Mata processos nas portas 3000 e 8080
	@echo "$(YELLOW)Matando processos nas portas 3000 e 8080...$(NC)"
	@lsof -ti :3000 | xargs kill -9 2>/dev/null || true
	@lsof -ti :8080 | xargs kill -9 2>/dev/null || true
	@echo "$(GREEN)Processos finalizados!$(NC)"

# Comandos de instalação de dependências do sistema
install-deps: ## Instala dependências do sistema (Ubuntu)
	@echo "$(BLUE)Instalando dependências do sistema...$(NC)"
	@./install-deps-ubuntu.sh

# Comandos de documentação
docs: ## Gera documentação
	@echo "$(BLUE)Gerando documentação...$(NC)"
	@echo "$(GREEN)Documentação disponível em README.md$(NC)"

# Comandos de deploy (futuro)
deploy-staging: ## Deploy para staging
	@echo "$(YELLOW)Deploy para staging não implementado$(NC)"

deploy-prod: ## Deploy para produção
	@echo "$(YELLOW)Deploy para produção não implementado$(NC)"

# Comando padrão
.DEFAULT_GOAL := help
