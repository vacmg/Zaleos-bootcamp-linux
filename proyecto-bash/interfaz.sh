#!/usr/bin/env bash

# Funciones auxiliares
# Func que concatena un 0 delante del número si este tiene solo una cifra
Concat (){
    local number="$1"
    Concat=${#number}
    LONG=2
    if [ "$Concat" -eq 1 ] 
    then
        LONG=1
        number="0$number"
    fi
    echo $number
}

# Func que asigna un número a cada día de la semana
Asign (){
    local day="$1"
    local number_day

    case "$day" in
        M)   number_day=1 ;;   # Lunes
        Tu)  number_day=2 ;;   # Martes
        W)   number_day=3 ;;   # Miércoles
        Th)  number_day=4 ;;   # Jueves
        F)   number_day=5 ;;   # Viernes
        Sa)  number_day=6 ;;   # Sábado
        Su)  number_day=7 ;;   # Domingo
    esac

    # Mostrar el número asignado
    echo $number_day
}

# Func que verifica que YEAR tenga formato YYYY
Year (){

    while [ $VALID -eq 1 ]
    do
        echo "YEAR? [YYYY]" 
        read YEAR
        clear
        if [[ $YEAR =~ ^[0-9]{4}$ ]] &&  [ $YEAR -gt 2023 ]
        then
            VALID=0
        else
            echo "INCORRECT MONTH!! try again"
        fi
    done
    VALID=1
}

# Func que verifica que MONTH sea un número entre 1 y 12, llama a Concat para que si es solo una cifra te concatene un 0 delante
Month (){

    while [ $VALID -eq 1 ]
    do
        echo "Month? [1-12]" 
        read MONTH
        clear
        if [[ $MONTH =~ ^[0-9]{1,2}$ ]] &&  [ $MONTH -gt 0 ] && [ $MONTH -le 12 ]
        then
            FORMATTED_MONTH=$(Concat "$MONTH")
            VALID=0
        else
            echo "INCORRECT MONTH!! try again"
        fi
    done
    VALID=1
}

# Func que mira DAY es un número o dos letras, si son dos letras y se comprueba que se quiere hacer una copia recurrente lo acepta sino no
Day (){

    while [ $VALID -eq 1 ]
    do
        if [ $PERIODICBACKUP = "y" ]
        then
            echo "Day? [01-31 | M,Tu,W,Th,F,Sa,Su]" 
            read DAY
            clear
            if [[ $DAY =~ ^[0-9]{1,2}$ ]] && [ $DAY -gt 1 ] && [ $DAY -le 31 ]
            then
                DAY_NUM=$(Concat "$DAY")
                DAY_WEEK=\*
                VALID=0
            elif [[ $DAY =~ ^(M|Tu|W|Th|F|Sa|Su)$ ]]
            then
                DAY_WEEK=$(Asign "$DAY")
                DAY_NUM=\*
                VALID=0
            else
                echo "WRONG FORMAT!! Try again"
            fi
        elif [ $PERIODICBACKUP = "n" ]
        then
            echo "Day? [1-31]" 
            read DAY
            clear
            if [[ $DAY =~ ^[0-9]{1,2}$ ]] && [ $DAY -gt 1 ] && [ $DAY -le 31 ]
            then
                DAY_NUM=$(Concat "$DAY")
                DAY_WEEK=\*
                VALID=0
            else
               echo "WRONG FORMAT!! Try again"
            fi 
        fi
    done
    VALID=1
}

# Func que comprueba que el formato de las horas sea el correcto y llama a Concat si es solo un dígito
Hour (){

    while [ $VALID -eq 1 ]
    do
        echo "Hour? [0-23]" 
        read HOUR
        clear
        if [[ $HOUR =~ ^[0-9]{1,2}$ ]] && [ $HOUR -ge 0 ] && [ $HOUR -lt 24 ]
        then
            FORMATTED_HOUR=$(Concat "$HOUR")
            VALID=0
        else
            echo "WRONG FORMAT!! Try again"
        fi
    done
    VALID=1
}

# Func que comprueba que el formato de los minutos sea el correcto y llama a Concat si es soo un dígito
Min (){

    while [ $VALID -eq 1 ]
    do
        echo "Minute? [0-59]" 
        read MIN
        clear
        if [[ $MIN =~ ^[0-9]{1,2}$ ]] && [ $MIN -ge 0 ] && [ $MIN -lt 60 ]
        then
            FORMATTED_MIN=$(Concat "$MIN")
            VALID=0
        else
            echo "WRONG FORMAT!! Try again"
        fi
    done
    VALID=1
}

#Cuestionario:
clear
echo Greetings my friend!!
sleep 0.5
clear

FLAG=1
VALID=1

while [ $FLAG -eq 1 ]
do
    echo "What do you want to do? [create, list, remove]"
    read MODE
    clear

    # Si quiere crear una copia de seguridad
    if [ $MODE = "create" ]
    then
        echo "Where do you have your files?"
        read SOURCE
        clear
        echo "In which path do you want to save the compressed file? (with the name of the compressed file)" 
        read DESTI
        clear

        while [ $VALID -eq 1 ]
        do
            echo "Do you want to make recurrent copies? [y/n]" 
            read PERIODICBACKUP
            clear
            if [ $PERIODICBACKUP = "y" ]
            then
                Month
                Day
                Hour
                Min
                bash backupConfig.sh create $SOURCE $DESTI $PERIODICBACKUP $FORMATTED_MIN $FORMATTED_HOUR $DAY_NUM $FORMATTED_MONTH $DAY_WEEK
                VALID=0
            elif [ $PERIODICBACKUP = "n" ]
            then
                while [ $VALID -eq 1 ]
                do
                    echo "Do you want to make a copy right now? [y/n]"
                    read NOW
                    clear
                    if [ $NOW = "n" ]
                    then
                        Year
                        Month
                        Day
                        Hour
                        Min
                        AT_FORMAT="$YEAR$FORMATTED_MONTH$DAY_NUM$FORMATTED_HOUR$FORMATTED_MIN.00"
                        bash backupConfig.sh create $SOURCE $DESTI $PERIODICBACKUP $AT_FORMAT
                        VALID=0
                    elif [ $NOW != "y" ]
                    then
                        echo "WRONG FORMAT!! Try again"
                    else
                        VALID=0
                    fi
                done
            else
                echo "WRONG FORMAT!! Try again"
            fi
        done
    else
        echo "WRONG FORMAT!! Try again"
    fi

    # Bucle para preguntar si quiere seguir o quiere cerrar
    while [ $VALID -eq 0 ]
    do
        echo "Anything else? [y/n]"
        read CONTINUE
        clear
        if [ $CONTINUE = "n" ]
        then 
            echo "BYE BYE"
            sleep 0.5
            clear
            exit 0
        elif [ ! $CONTINUE = "y" ]
        then 
            echo "WRONG FORMAT!! Try again"
        else
            VALID=1
        fi
    done

    echo "mode: $MODE
    source: $SOURCE
    desti: $DESTI
    periodicBackup: $PERIODICBACKUP"
        
    echo "YEAR: $YEAR 
    MES: $FORMATTED_MONTH    
    DIA_SEM: $DAY_WEEK
    DIA_NUM: $DAY_NUM
    HORA: $FORMATTED_HOUR 
    MIN: $FORMATTED_MIN
    AT_FORMAT: $AT_FORMAT"
done