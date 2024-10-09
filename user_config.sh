#!/bin/bash

# Функция для чтения настроек из файла settings.env
load_settings() {
    if [ -f settings.env ]; then
        # Читаем файл и извлекаем значение CONTAINER_NAME
        CONTAINER_NAME=$(grep "CONTAINER_NAME" settings.env | cut -d '=' -f2 | xargs)
    else
        echo "Ошибка: файл settings.env не найден."
        exit 1
    fi
}

# Функция для получения списка пользователей
get_user_list() {
    sudo docker exec -i "$CONTAINER_NAME" cat /etc/"$CONTAINER_NAME"/ocpasswd | cut -d ':' -f1
}

# Функция для главного меню
main_menu() {
    while true; do
        # Получаем список пользователей
        USERS=$(get_user_list)
        MENU_USERS=""
        for USER in ${USERS}; do
            MENU_USERS="${MENU_USERS} ${USER} -"
        done

        # Показываем меню диалога
        OPTION=$(dialog --clear --stdout --title "База пользователей" --menu "Выберите пользователя или добавьте:" 15 50 7 \
            "Add" "Добавить" \
            ${MENU_USERS})
        
        # Обработка выбранного пункта меню
        case "$OPTION" in
            "Add")
                add_user
                ;;
            "")
                # Пользователь нажал Cancel
                clear
                exit 0
                ;;
            *)
                user_menu "$OPTION"
                ;;
        esac
    done
}

# Функция для меню пользователя
user_menu() {
    USERNAME=$1
    ACTION=$(dialog --clear --stdout --title "Опции для $USERNAME" --menu "Выберите действие:" 15 50 5 \
        "Delete" "Удалить" \
        "ChangePassword" "Изменить пароль" \
        "Block" "Блокировать" \
        "Unblock" "Разблокировать")

    case "$ACTION" in
        "Delete")
            delete_user "$USERNAME"
            ;;
        "ChangePassword")
            change_password "$USERNAME"
            ;;
        "Block")
            block_user "$USERNAME"
            ;;
        "Unblock")
            unblock_user "$USERNAME"
            ;;
        "")
            # Пользователь нажал Cancel
            return
            ;;
    esac
}

# Функция для добавления нового пользователя
add_user() {
    NEW_USER=$(dialog --stdout --inputbox "Введите имя нового пользователя:" 8 40)
    if [ ! -z "$NEW_USER" ]; then
        NEW_PASS=$(dialog --stdout --inputbox "Введите пароль:" 8 40)
        if [ ! -z "$NEW_PASS" ]; then
            echo "$NEW_PASS" | sudo docker exec -i "$CONTAINER_NAME" ocpasswd -c /etc/"$CONTAINER_NAME"/ocpasswd "$NEW_USER"
        fi
    fi
}

# Функция для удаления пользователя
delete_user() {
    USERNAME=$1
    sudo docker exec -i "$CONTAINER_NAME" ocpasswd -c /etc/"$CONTAINER_NAME"/ocpasswd -d "$USERNAME"
}

# Функция для смены пароля
change_password() {
    USERNAME=$1
    NEW_PASS=$(dialog --stdout --inputbox "Введите новый праоль для $USERNAME:" 8 40)
    if [ ! -z "$NEW_PASS" ]; then
        echo "$NEW_PASS" | sudo docker exec -i "$CONTAINER_NAME" ocpasswd -c /etc/"$CONTAINER_NAME"/ocpasswd "$USERNAME"
    fi
}

# Функция для блокировки пользователя
block_user() {
    USERNAME=$1
    sudo docker exec -i "$CONTAINER_NAME" ocpasswd -c /etc/"$CONTAINER_NAME"/ocpasswd -l "$USERNAME"
}

# Функция для разблокировки пользователя
unblock_user() {
    USERNAME=$1
    sudo docker exec -i "$CONTAINER_NAME" ocpasswd -c /etc/"$CONTAINER_NAME"/ocpasswd -u "$USERNAME"
}

# Главное меню
load_settings
main_menu
