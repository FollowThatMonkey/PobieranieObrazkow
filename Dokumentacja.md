Dokumentacja skryptu
====================

## Struktura działania  
1. Skrypt sprawdza czy podana została opcja `-h`
   * Jeśli tak, to skrypt wyświetla pomoc i kończy działanie
2. Skrypt sprawdza czy została podana odpowiednia liczba argumentów (wymagany jeden argument - strona WWW).
   * Jeśli podana została błędna liczba argumentów, to skrypt wyświetla komunikat błędu i kończy działanie.
3. Skrypt pobiera przy użyciu programu `wget` zadaną stronę WWW dopliku tymczasowego.
   * Jeśli pobieranie nie powiedzie się, to skrypt wyświetla komunikat błędu i kończy działanie.
4. Skrypt przy użyciu programu `grep` wyszukuje znaczniki `<img src="obrazek.png">` lub `<img src="obrazek.jpg">` i przypisuje wyszukane linie do zmiennej.
5. Skrypt dopasowuje odpowiednio sposób podanej ścieżki tak, aby pobrać dany obrazek (w tym celu wykorzystano programy `grep` oraz `sed`).
6. Skrypt pobiera znalezione obrazki używając programu `wget`.
7. Po zakończeniu pobierania wszystkich obrazków, program usuwa plik tymczasowy komendą `rm`.

-----------------------

## Analiza kodu skryptu

### Główna część programu
1. Utworzenie niezbędnych do dalszego działania zmiennych.
```bash
temp_file=temp_file # nazwa pliku tymczasowego
url="" # zmienna przechowująca adres strony internetowej z której pobrane zostaną obrazki
```

2. Sprawdzenie opcji programu. Jeśli została wywołana opcja `-h`, to skrypt wyświetli pomoc (wywoła funkcję `wyswietl_help()`) i zakończy działanie skryptu.
```bash
while getopts "h" option; do
	case $option in
		h)
			wyswietl_help
			exit;;
	esac
done
```

3. Sprawdzenie czy podany został jeden adres WWW. Jśli nie, to skrypt wyświetla komunikat błędu i kończy działanie. W przeciwnym wypadku do zmiennej `url` zostaje przypisany pierwszy argument skryptu i zostają wywłoane funkcje: `pobierz`, `obrazki` oraz `usun`.
```bash
if [ $# -eq 1 ]
then
	url=$1 # przypisanie adresu strony do zmiennej url
	pobierz $1 # pobiera stronę do pliku tymczasowego
	obrazki # pobiera obrazki
	usun # usuwa plik tymczasowy
else
	echo "Podana błędna liczba argumentów. Wymagana liczba argumentów to 1."
fi
```

### Funkcja `pobierz()`
4. Skrypt analizuje, czy na końcu podanego adresu URL znajduje się slesz. Jeśli go tam nie ma, to go dodaje. Proces ten jest wymagany do prawidłowego działania pobierania plików w dalszej części programu (dokładniej do prawidłowego działania funkcji `obrazki()`).
```bash
pobierz () {
	if [[ "$url" != */ ]] # Jeśli brak slesza na końcu linku strony, to go dodaj (parsowanie wymagane do daleszej części programu)
	then
		url="${url}/"
	fi
```

5. Kolejno wykonywana jest próba pobrania zadanej strony do pliku tymczasowego przy użyciu programu `wget`. Opcje: `-q` oznacza wyłączenie wypisywania komunikatów przez program, `-O` oznacza zapisanie pobranej strony do zadanego pliku (w moim przypadku nazwa pliku jest przechowywana w zmiennej `$temp_file`).
```bash
wget -qO $temp_file $1
```

6. Następnie sprawdzane jest, czy pobranie strony przebiegło pomyślnie. W przypadku niepowodzenia program wypisuje komunikat błędu, usuwa plik tymczasowy korzystając z funkcji `usun()` i kończy działanie całego skryptu.
```bash
	if [ $? -ne 0 ] # jeśli wget nie potrafi pobrać zadanej strony, to zakończ skrypt
	then
		echo "Podano błędny adres strony"
		usun # usunięcie pliku tymczasowego (wget nawet w przypadku błędu pobierania utworzy zadany plik tymczasowy)
		exit 1
	fi
}
```

### Funkcja `obrazki()`
7. Do zmiennej `obrazy` zostają przypisane linki do obrazków. Linki do obrazków zostają wyszukane z pliku tymczasowego przy pomocy programu `grep`. Wywołane opcje dla tego programu to: `-o` zwraca jedynie pasujący fragment tekstu (nie całą linię), `-P` tryb wyrażeń regularnych zgodnych z `Perl`, `-e` użycie podanego wzorca. Podany przeze mnie wzorzec, to: `src.*?(jpg|png)`, co oznacza, że `grep` wyszuka frazę która zaczyna się od liter `src`, natomiast kończy się literami `jpg` lub `png`. Kolejno, korzystając z programu `sed`, usunięta zostaje część tekstu `src="`, a więc, dla przykładu, z tekstu `src="obrazek.jpg"` pozostaje `obrazek.jpg`.
```bash
obrazki () { 
	obrazy=$(grep -oPe "src.*?(jpg|png)" $temp_file | sed 's/src=\"//g')
```

8. Kolejno, tworzę pętlę `for` iterującą po przygotowanych wcześniej linkach - zawartych w zmiennej `$obrazy`.
```bash
	for i in $obrazy
		do
```

9. Następnie należy rozważyć trzy przypadki na jaki może być podany link do zdjęcia.
	* Linki mogą być podane bezpośrednio, a więc na przykład: `html://strona.com/obrazek.jpg`. Jeśli tak jest, to można pobrać dany obrazek bez dalszej obróbki zadanego linku. Sprawdzenie czy link jest podany bezpośrednio jest wykonane wykorzystując program `grep`. Użyte wyrażenie `^(ht)` zwraca tekst zaczynający się od liter `ht`. Takim tekstem jest np. `http://strona.com/obrazek.jpg`.
	```bash
		if [ $(echo $i | grep -Pe "^(ht)") ] # wyrażenie ^(ht) zwraca wyrażenie zaczynające się od liter ht - np. http://...
				then
					wget -q $i
	```

	* Drugi przypadek to gdy podany link odnosi się do głównego katalogu danej strony internetowej, a więc np. `/folder/obrazek.jpg`. Sprawdzenie czy link ma taką postać jest wykonane wykorzystując program `grep`. Użyte wyrażenie `^/` zwraca wyrażenia zaczynająca się od znaku `/`, a więc np. `/folder/obrazek.jpg`. Kolejno, przy użyciu programu `grep`, do zmiennej `url2` zostaje przypisana główna strona danego URL. Wyrażenie `^.*?\b\/` wyszukuje dowolny ciąg znaków, po którym następuje ciąg liter zakończony sleszem, więc z tekstu `http://strona.com/podstrona/` zostanie wyekstraktowany tekst `http://strona.com/`. Następnie do zmiennej `$obrazek2` zostaje przypisany link do obrazka, jednocześnie usuwając z niego slesza od którego się rozpoczyna, a wieć z linku `/folder/obrazek.jpg` pozostanie `folder/obrazek.jpg`. Ostatecznie przy pomocy programu `wget` zostaje pobrany link powstały ze złączenia zmiennych `$url2` oraz `$obrazek2`, a więc dla przykładu frazy `http://strona.com/` oraz `folder/obrazek.jpg` zostaną złączone w `http://strona.com/folder/obrazek.jpg`.
	```bash
		elif [ $(echo $i | grep -Pe "^/") ] # przypadek jeżeli link ma wzór typu 'src="/folder/obrazek.jpg"'
			then
				# zapisanie linku jako np. 'http://strona.com/' - katalog główny podanej strony
				url2=$(echo $url | grep -oPe "^.*?\b\/") # wyrażenie ^.*?\b\/ wyszukuje pierwsze słowo kończące się sleszem, np. http://moja.strona.com/podstrona/ --> http://moja.strona.com/
				# zapisanie ścieżki względniej jako np. 'folder/zdjęcie.jpg'
				obrazek2=$(echo $i | sed 's/\///')
				# utworzenie linku do pobrania obrazka przez złączenie 'http://strona.com/' + 'folder/zdjęcie.jpg' w 'http://strona.com/folder/zdjęcie.jpg'
				wget -q "${url2}${obrazek2}"
	```

	* Ostatni przypadek, to gdy link został podany jako ścieżka względna. W takim przypadku link do pobrania danego zdjęcia powstaje ze złączenia zmiennych `$url` oraz `$i`, a więc np. ze złączenia frazy `http://strona.com/podstrona/` oraz `../folder/obrazek.jpg` we frazę `http://strona.com/podstrona/../folder/obrazek.jpg`. Taki link do obrazka jest odpowiedni do pobrania przez program `wget`.
	```bash
			else # przypadek gdy obrazek jest w folderze znajdującym się w aktualnym folderze. Link ma wzór 'src="folder/zdjęcie.jpg"'
				wget -q "${url}${i}" # utworzenie linku do pobrania obrazka przez złączenie adresu strony i adresu zdjęcia
			fi
		done
	}
	```

### Funkcja `usun()`
10. Po pobraniu obrazków zostaje wywołana funkcja `usun()`, która usuwa plik tymczasowy, po czym następuje zakończenie działania skryptu.
```bash
usun () { 
	rm $temp_file
}
```