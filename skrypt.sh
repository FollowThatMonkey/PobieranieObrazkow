#!/bin/bash

#######################
## Definicje funkcji ##
#######################

# Funkcja pobierająca stronę www do pliku tymczasowego
pobierz () {
	if [[ "$url" != */ ]] # Jeśli brak slesza na końcu linku strony, to go dodaj (parsowanie wymagane do daleszej części programu)
	then
		url="${url}/"
	fi

	# wget = pobieranie strony www
	# flaga -q = bez wyświetlania komunikatów
	# flaga -O = zapisz do podanego pliku
	wget -qO $temp_file $1

	if [ $? -ne 0 ] # jeśli wget nie potrafi pobrać zadanej strony, to zakończ skrypt
	then
		echo "Podano błędny adres strony"
		usun # usunięcie pliku tymczasowego (wget nawet w przypadku błędu pobierania utworzy zadany plik tymczasowy)
		exit 1
	fi
}

# Funkcja wyszukująca i pobierająca obrazki - analizuje plik tymczasowy
obrazki () { 
	# przypisanie linków do obrazków (ścieżki względne/bezwzgl.) do zmiennej $obrazki
	# grep -oPe 'regex' = wyszukuje wyrażenia regularne w trybie zgodność z Perl'em. Wyrażenia typu 'src...jpg' lub 'src...png'
	# sed 's/src=\"//g' = zamienia z podanego strumienia zadane wyrażenie regularne (w moim przypadku zamienia wyrażenie 'src="' na pusty znak - czyli go usuwa)
	obrazki=$(grep -oPe "src.*?(jpg|png)" $temp_file | sed 's/src=\"//g')

	# pętla iterująca po wszystkich znalezionych linkach do obrazków
	for i in $obrazki
	do
		#jeżeli podany jest bezpośredni link do obrazka to go pobierz (link typu 'src="http://pw.edu.pl/obrazek.jpg')
		if [ $(echo $i | grep -Pe "^(ht)") ] # wyrażenie ^(ht) zwraca wyrażenie zaczynające się od liter ht - np. http://...
		then
			wget -q $i
		elif [ $(echo $i | grep -Pe "^/") ] # przypadek jeżeli link ma wzór typu 'src="/folder/obrazek.jpg"'
		then
			# zapisanie linku jako np. 'http://strona.com/' - katalog główny podanej strony
			url2=$(echo $url | grep -oPe "^.*?\b\/") # wyrażenie ^.*?\b\/ wyszukuje pierwsze słowo kończące się sleszem, np. http://moja.strona.com/podstrona/ --> http://moja.strona.com/
			# zapisanie ścieżki względniej jako np. 'folder/zdjęcie.jpg'
			obrazek2=$(echo $i | sed 's/\///')
			# utworzenie linku do pobrania obrazka przez złączenie 'http://strona.com/' + 'folder/zdjęcie.jpg' w 'http://strona.com/folder/zdjęcie.jpg'
			wget -q "${url2}${obrazek2}"
		else # przypadek gdy obrazek jest w folderze znajdującym się w aktualnym folderze. Link ma wzór 'src="folder/zdjęcie.jpg"'
			wget -q "${url}${i}" # utworzenie linku do pobrania obrazka przez złączenie adresu strony i adresu zdjęcia
		fi
	done
}

# usuwa plik tymczasowy
usun () { 
	rm $temp_file
}

# pomoc wyświetlana po uruchomieniu skryptu z flagą -h
wyswietl_help () {
	echo "Skrypt pobierający obrazki .jpg oraz .png z podanej strony WWW."
	echo "Aby pobrać obrazki z danej strony internetowej, podaj ją jako argument skryptu."
	echo "Przykładowe użycie programu: $0 http://www.fizyka.pw.edu.pl/"
}


#############################
## Właściwa część programu ##
#############################

temp_file=temp_file # nazwa pliku tymczasowego
url="" # zmienna przechowująca adres strony internetowej z której pobrane zostaną obrazki

# sprawdzenie argumentów skryptu - jeśli został podany arg h, to zostanie wyświetlona pomoc
while getopts "h" option; do
	case $option in
		h)
			wyswietl_help
			exit;;
	esac
done


# wymagany 1 argument (strona z której mają być pobrane obrazki)
if [ $# -eq 1 ]
then
	url=$1 # przypisanie adresu strony do zmiennej url
	pobierz $1 # pobiera stronę do pliku tymczasowego
	obrazki # pobiera obrazki
	usun # usuwa plik tymczasowy
else
	echo "Podana błędna liczba argumentów. Wymagana liczba argumentów to 1."
fi
