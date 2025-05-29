#!/bin/bash

# Цвета текста
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # Нет цвета (сброс цвета)

# Проверка наличия curl и установка, если не установлен
if ! command -v curl &> /dev/null; then
    sudo apt update
    sudo apt install curl -y
fi
sleep 1

# Отображаем логотип
curl -s https://raw.githubusercontent.com/sk1fas/logo-sk1fas/main/logo-sk1fas.sh | bash

# Меню
echo -e "${YELLOW}Выберите действие:${NC}"
echo -e "${CYAN}1) Установка ноды${NC}"
echo -e "${CYAN}2) Регистрация ноды${NC}"
echo -e "${CYAN}3) Просмотр логов${NC}"
echo -e "${CYAN}4) Рестарт ноды${NC}"
echo -e "${CYAN}5) Обновление ноды${NC}"
echo -e "${CYAN}6) Удаление ноды${NC}"

echo -e "${YELLOW}Введите номер:${NC} "
read choice

case $choice in
    1)
        echo -e "${BLUE}Установка зависимостей...${NC}"
        sudo apt-get update && sudo apt-get upgrade -y
        sudo apt install iptables-persistent
        sudo apt install curl iptables build-essential git wget lz4 jq make gcc nano automake autoconf tmux htop nvme-cli libgbm1 pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip libleveldb-dev  -y
        
        echo -e "${BLUE}Проверяем Docker и Docker-Compose...${NC}"
        if ! bash <(curl -fsSL https://raw.githubusercontent.com/sk1fas/docker_main.sh/main/docker_main.sh); then
          echo -e "${RED}Не удалось установить Docker/Compose${NC}" >&2
          exit 1
        fi
        
        git clone https://github.com/Blockcast/beacon-docker-compose.git
        cd beacon-docker-compose

        # Определяем, какой синтаксис compose доступен
        if command -v docker-compose &> /dev/null; then
          DC="docker-compose"
        elif docker compose version &> /dev/null; then
          DC="docker compose"
        else
          echo "Ошибка: не найдено ни команды 'docker-compose', ни команды 'docker compose'." >&2
          exit 1
        fi
        
        $DC up -d
      
        cd ~
        # Завершающий вывод
        echo -e "${PURPLE}-----------------------------------------------------------------------${NC}"
        echo -e "${YELLOW}Команда для проверки логов:${NC}" 
        echo "docker logs -f blockcastd"
        echo -e "${PURPLE}-----------------------------------------------------------------------${NC}"
        echo -e "${GREEN}Sk1fas Journey${NC}"
        echo -e "${CYAN}Telegram https://t.me/Sk1fasCryptoJourney${NC}"
        sleep 2
        docker logs -f blockcastd   
        ;;
    2)
        echo -e "${BLUE}Получаю данные для регистрации...${NC}"
        cd beacon-docker-compose
        sleep 2

        # Определяем, какой синтаксис compose доступен
        if command -v docker-compose &> /dev/null; then
          DC="docker-compose"
        elif docker compose version &> /dev/null; then
          DC="docker compose"
        else
          echo "Ошибка: не найдено ни команды 'docker-compose', ни команды 'docker compose'." >&2
          exit 1
        fi
        
        $DC exec blockcastd blockcastd init
        cd ~
        ;;
    3)
        docker logs -f blockcastd
        ;;
    4)
        echo -e "${BLUE}Перезапускаю контейнеры ноды...${NC}"
        cd beacon-docker-compose

        # Определяем, какой синтаксис compose доступен
        if command -v docker-compose &> /dev/null; then
          DC="docker-compose"
        elif docker compose version &> /dev/null; then
          DC="docker compose"
        else
          echo "Ошибка: не найдено ни команды 'docker-compose', ни команды 'docker compose'." >&2
          exit 1
        fi
        
        $DC restart
        cd ~
        sleep 2
        docker logs -f blockcastd
        ;;
    5)
        echo -e "${GREEN}У вас актуальная версия ноды!${NC}"
        ;;
    6)
        echo -e "${BLUE}Удаление ноды Blockcast...${NC}"
        cd ~/beacon-docker-compose

        # Определяем, какой синтаксис compose доступен
        if command -v docker-compose &> /dev/null; then
          DC="docker-compose"
        elif docker compose version &> /dev/null; then
          DC="docker compose"
        else
          echo "Ошибка: не найдено ни команды 'docker-compose', ни команды 'docker compose'." >&2
          exit 1
        fi
        
        $DC down --rmi all --volumes --remove-orphans
        cd ~
        rm -rf beacon-docker-compose
        rm -rf ~/.blockcast
        ;;
    *)
        echo -e "${RED}Неверный выбор! Пожалуйста, выберите пункт из меню.${NC}"
        ;;
esac