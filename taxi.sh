#!/bin/bash

declare -a taxi_vehicles
declare -a voznje
declare wallet=0
YELLOW='\033[0;33m'

# Funkcija za prijavu korisnika
login() {
clear
    read -p "Unesite korisničko ime: " username
    read  -p "Unesite lozinku: " password

    # Provjera korisničkog imena i lozinke (moguće provjeriti u bazi podataka ili nekom drugom izvoru podataka)
    if [[ "$username" == "Kotlin" && "$password" == "getpassword" ]]; then
         clear
        admin_menu
    elif [[ "$username" == "Java" && "$password" == "finaluser" ]]; then
        clear
        user_menu
    else
        echo "Pogrešni podaci. Pokušajte ponovo."
        sleep 3
        clear
        login_menu
    fi
}
deposit_money() {
    clear
    read -p "Unesite iznos koji želite uplatiti: " amount

    # Dodavanje iznosa na korisnički račun
    wallet=$((wallet+amount))

    clear
    echo "Uplata je uspješno izvršena"
    echo "Stanje na racunu je $wallet$"
    sleep 3
    clear
}

# Funkcija za prikaz admin menija
admin_menu() {
clear
    while true
    do
        echo "Dobrodošli, gospodine $username!"
        echo "*Odaberite opciju: *"
        echo "*1. Dodaj novo taksi vozilo*"
        echo "*2. Uredi informacije o taksi vozilima*"
        echo "*3. Pregled informacija o vožnjama*"
        echo "*4. Obriši taksi vozilo*"
        echo "*5. Odjava*"

        read -p "Unesite opciju: " choice

        case $choice in
            1)
            clear
                add_taxi_vehicle
                ;;
            2)
            clear
                edit_taxi_vehicle
                ;;
            3)
            clear
                view_trip_information
                ;;
            4)
            clear
                delete_taxi_vehicle
                ;;
            5)
               clear
                echo "Hvala vam! Doviđenja."
                sleep 3
                login_menu
                break
                ;;
            *)
                echo "Nepoznata opcija. Molimo pokušajte ponovo."
                ;;
        esac
    done
}

# Funkcija za prikaz korisničkog menija
user_menu() {
    clear
    while true
    do
        echo *"Dobrodošli, $username!*"
        echo "Odaberite opciju: "
        echo "*1. Rezerviši taksi vozilo*"
        echo "*2. Pregled informacija o vožnjama*"
        echo "*3. Pokreni vožnju*"
        echo "*4. Uplati novac*"
        echo "*5. Odjava*"

        read -p "Unesite opciju: " choice

        case $choice in
            1)
                clear
                book_taxi
                ;;
            2)
                clear
                view_trip_information
                ;;
            3)
                clear
                start_ride
                ;;
            4)
                clear
                deposit_money
                ;;
            5)
                clear
                echo "Hvala vam! Doviđenja."
                login_menu
                break
                ;;
            *)
                echo "Nepoznata opcija. Molimo pokušajte ponovo."
                ;;
        esac
    done
}

# Funkcija za dodavanje novog taksi vozila
add_taxi_vehicle() {
    echo "Unesite informacije o novom taksi vozilu: "
    read -p "Registarska oznaka: " registration_number
    read -p "Model: " model
    read -p "Godina proizvodnje: " year
    read -p "Broj sjedišta: " seats

    taxi_vehicles+=("$registration_number, $model, $year, $seats,0")
    clear
    echo "Novo taksi vozilo je uspješno dodano."
    sleep 3
    clear
}
load_taxi_vehicles() {
    if [[ -f "vozila.dat" ]]; then
        while IFS= read -r line; do
            taxi_vehicles+=("$line")
        done < "vozila.dat"
    fi
}
save_taxi_vehicles() {
    for vehicle in "${taxi_vehicles[@]}"; do
        echo "$vehicle" >> "vozila.dat"
    done
}


# Funkcija za uređivanje informacija o taksi vozilima
edit_taxi_vehicle() {
    echo "Odaberite taksi vozilo koje želite urediti: "
    select vehicle in "${taxi_vehicles[@]}"
    do
        IFS=", " read -ra vehicle_info <<< "$vehicle"
        echo "Odabrano taksi vozilo: $vehicle"
        echo "1. Registarska oznaka: ${vehicle_info[0]}"
        echo "2. Model: ${vehicle_info[1]}"
        echo "3. Godina proizvodnje: ${vehicle_info[2]}"
        echo "4. Broj sjedišta: ${vehicle_info[3]}"
        echo "5. Odustani"

        read -p "Unesite opciju koju želite urediti: " option

        case $option in
            1)
                read -p "Unesite novu registarsku oznaku: " registration_number
                vehicle_info[0]=$registration_number
                echo "Registarska oznaka je uspješno promijenjena."
                ;;
            2)
                read -p "Unesite novi model: " model
                vehicle_info[1]=$model
                echo "Model je uspješno promijenjen."
                ;;
            3)
                read -p "Unesite novu godinu proizvodnje: " year
                vehicle_info[2]=$year
                echo "Godina proizvodnje je uspješno promijenjena."
                ;;
            4)
                read -p "Unesite novi broj sjedišta: " seats
                vehicle_info[3]=$seats
                echo "Broj sjedišta je uspješno promijenjen."
                ;;
            5)
                echo "Odustali ste od uređivanja."
                break
                ;;
            *)
                echo "Nepoznata opcija. Molimo pokušajte ponovo."
                ;;
        esac

        updated_vehicle_info="${vehicle_info[*]}"
        taxi_vehicles=("${taxi_vehicles[@]/$vehicle/$updated_vehicle_info}")
        clear
        echo "Informacije o taksi vozilu su uspješno ažurirane."
        sleep 3
        clear
        break
    done
}

# Funkcija za pregled informacija o vožnjama
view_trip_information() {
    if [[ ${#voznje[@]} -eq 0 ]]; then
        echo "Trenutno nema dostupnih informacija o vožnjama."
    else
        echo "Informacije o vožnjama: "
        for trip in "${voznje[@]}"
        do
            echo "$trip"
        done
    fi
    sleep 3
    clear
}

# Funkcija za brisanje taksi vozila
delete_taxi_vehicle() {
    echo "Odaberite taksi vozilo koje želite obrisati: "
    select vehicle in "${taxi_vehicles[@]}"
    do
        taxi_vehicles=("${taxi_vehicles[@]/$vehicle}")
        clear
        echo "Taksi vozilo je uspješno obrisano."
        sleep 3
        break
    done
    clear
}

book_taxi() {
    echo "Rezervacija taksi vozila:"
    read -p "Unesite broj sjedišta: " seats
    available_vehicles=()

    for vehicle in "${taxi_vehicles[@]}"
    do
        IFS=", " read -ra vehicle_info <<< "$vehicle"
        if [[ ${vehicle_info[3]} -ge $seats ]] && [[ ${vehicle_info[4]} -eq 0 ]]; then
            available_vehicles+=("${vehicle_info[1]}")  
        fi
    done

    if [[ ${#available_vehicles[@]} -eq 0 ]]; then
        echo "Nema dostupnih taksi vozila sa zadovoljavajućim brojem sjedišta ili su već rezervisana."
        sleep 3
        clear
    else
        echo "Dostupna taksi vozila sa zadovoljavajućim brojem sjedišta: "
        select vehicle in "${available_vehicles[@]}"
        do
            if [[ -n $vehicle ]]; then
                for i in "${!taxi_vehicles[@]}"
                do
                    IFS=", " read -ra vehicle_info <<< "${taxi_vehicles[$i]}"
                    if [[ ${vehicle_info[1]} == "$vehicle" ]]; then  # Promjena ovdje - provjeravamo model vozila umjesto registarskih tablica
                        taxi_vehicles[$i]="${vehicle_info[0]}, ${vehicle_info[1]}, ${vehicle_info[2]}, ${vehicle_info[3]}, 1"
                        echo "Taksi vozilo $vehicle rezervisano."
                        break
                    fi
                done
                break
            else
            clear
                echo "Pogrešan unos, molimo pokušajte ponovno."
                sleep 1  
            fi
        done
    fi
}
start_ride() {
    echo "Pokretanje vožnje..."

    available_vehicles=()
    flag=0

    for i in "${!taxi_vehicles[@]}"
    do
        IFS=", " read -ra vehicle_info <<< "${taxi_vehicles[$i]}"
        if [[ ${vehicle_info[4]} -eq 1 ]]; then
            available_vehicles+=("$i")
            flag=1
        fi
    done

    if [[ $flag -eq 0 ]]; then
        echo "Nema aktivnih vožnji."
    else
        echo "Dostupna vozila koja su spremna za vožnju: "
        select index in "${available_vehicles[@]}"
        do
            if [[ -n $index ]]; then
                IFS=", " read -ra vehicle_info <<< "${taxi_vehicles[1]}"
                echo "Pokretanje vožnje s vozilom ${vehicle_info[1]}..."

                # Unos adrese
                read -p "Unesite adresu do koje treba voziti taksi: " adresa

                # Generiranje slučajne cijene vožnje
                random_cijena=$((RANDOM%100 + 10))
                echo "Cijena vožnje: $random_cijena"

                # Provjera dostupnosti novca na korisničkom računu
                if [[ $random_cijena -gt $wallet ]]; then
                    echo "Nemate dovoljno novca na računu za pokretanje vožnje."
                    sleep 3
                    clear
                    return
                fi

                # Petlja za provjeru plaćanja
                while true
                do
                    read -p "Unesite 'plati' za plaćanje: " placanje
                    if [[ $placanje == "plati" ]]; then
                        echo "Plaćanje uspješno obavljeno."
                        break
                    else
                        sleep 1
                        echo "Pogrešan unos, molimo pokušajte ponovno."
                        clear
                    fi
                done

                clear
                echo "Voznja uskoro pocinje..."
                sleep 1
                clear
                udaljenost=("*" "*" "*" "*" "*")
                for ((i=0; i<5; i++))
                do
                    echo
                    udaljenost[i]="T"
                    if ((i>=1))
                    then
                        udaljenost[i-1]="*"
                        sleep 1
                        clear
                    fi
                    for ((j=0; j<5; j++))
                    do
                        if ((j==4))
                        then
                            echo -n "${udaljenost[j]}"
                        else
                            echo -n "${udaljenost[j]}-> "
                        fi
                    done
                done
                echo
                clear
                echo "Stigli ste do destinacije"
                sleep 1
                # Upis podataka o vožnji u niz voznje
                voznje+=("${vehicle_info[0]}, ${adresa}, ${random_cijena}")

                taxi_vehicles[$index]="${vehicle_info[0]}, ${vehicle_info[1]}, ${vehicle_info[2]}, ${vehicle_info[3]}, 0"
                wallet=$((wallet - random_cijena))  # Oduzimanje cijene vožnje iz novčanika
                break
            else
                clear
                echo "Pogrešan unos, molimo pokušajte ponovno."
                sleep 1
            fi
        done
    fi
    clear
}
login_menu() {
clear
    while true
    do
        echo "**WELCOME TO TAXI** "
        echo "*Odaberite opciju: *"
        echo "*1. Log in *"
        echo "*2. Exit   *"

        read -p "Unesite opciju: " option

        case $option in
            1)
                echo "Odabrali ste opciju Log in."
                login
                break
                ;;
            2)
            clear
                echo "Hvala vam! Doviđenja."
                sleep 2
                clear
                break
                ;;
            *)
                echo "Nepoznata opcija. Molimo pokušajte ponovo."
                ;;
        esac
    done
}

load_taxi_vehicles
login_menu
save_taxi_vehicles
