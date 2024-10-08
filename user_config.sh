#!/bin/bash

# Функция для генерации случайного пароля
generate_random_password() {
    # Генерация пароля из 12 символов
    tr -dc A-Za-z0-9 </dev/urandom | head -c 12 ; echo ''
}

# Проверка существования файла со списком пользователей
PASSWORD_FILE="/etc/ocserv/ocpasswd"
if ! sudo docker exec -i ocserv test -f "$PASSWORD_FILE"; then
    echo "User password file does not exist. Creating a default user."

    RANDOM_PASSWORD=$(generate_random_password)
    echo "Generated random password: $RANDOM_PASSWORD"

    echo "$RANDOM_PASSWORD" | sudo docker exec -i ocserv ocpasswd -c "$PASSWORD_FILE" "myusername"
    echo "User 'myusername' created with a random password."
fi


# Функция для получения списка пользователей
get_user_list() {
    sudo docker exec -i ocserv cat /etc/ocserv/ocpasswd | cut -d ':' -f1
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
        OPTION=$(dialog --clear --stdout --title "User Management" --menu "Select a user or option:" 15 50 7 \
            "Add" "Add new user" \
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
    ACTION=$(dialog --clear --stdout --title "Actions for $USERNAME" --menu "Select an action:" 15 50 5 \
        "Delete" "Delete user" \
        "ChangePassword" "Change password" \
        "Block" "Block user" \
        "Unblock" "Unblock user")

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
    NEW_USER=$(dialog --stdout --inputbox "Enter new username:" 8 40)
    if [ ! -z "$NEW_USER" ]; then
        NEW_PASS=$(dialog --stdout --passwordbox "Enter password:" 8 40)
        if [ ! -z "$NEW_PASS" ]; then
            echo "$NEW_PASS" | sudo docker exec -i ocserv ocpasswd -c /etc/ocserv/ocpasswd "$NEW_USER"
        fi
    fi
}

# Функция для удаления пользователя
delete_user() {
    USERNAME=$1
    sudo docker exec -i ocserv ocpasswd -c /etc/ocserv/ocpasswd -d "$USERNAME"
}

# Функция для смены пароля
change_password() {
    USERNAME=$1
    NEW_PASS=$(dialog --stdout --passwordbox "Enter new password for $USERNAME:" 8 40)
    if [ ! -z "$NEW_PASS" ]; then
        echo "$NEW_PASS" | sudo docker exec -i ocserv ocpasswd -c /etc/ocserv/ocpasswd "$USERNAME"
    fi
}

# Функция для блокировки пользователя
block_user() {
    USERNAME=$1
    sudo docker exec -i ocserv ocpasswd -c /etc/ocserv/ocpasswd -l "$USERNAME"
}

# Функция для разблокировки пользователя
unblock_user() {
    USERNAME=$1
    sudo docker exec -i ocserv ocpasswd -c /etc/ocserv/ocpasswd -u "$USERNAME"
}

# Главное меню
main_menu
