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

2. Sprawdzenie opcji programu. Jeśli została wywołana opcja `-h`, to skrypt wyświetli pomoc i zakończy działanie.
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
7. Do zmiennej `obrazy` zostaje przypisany link do obrazków. Linki do obrazków zostają wyszukane przy pomocy programu `grep`. Wywołane opcje dla tego programu to: `-o` zwraca jedynie pasujący fragment tekstu (nie całą linię), `-P` tryb wyrażeń regularnych zgodnych z `Perl`, `-e` użycie podanego wzorca. Podany przeze mnie wzorzec, to: `src.*?(jpg|png)`, co oznacza, że `grep` wyszuka frazę która zaczyna się od liter `src`, natomiast kończy się literami `jpg` lub `png`. Kolejno, korzystając z programu `sed`, usunięta zostaje część tekstu `src="`, a więc, dla przykładu, z tekstu `src="obrazek.jpg"` pozostaje `obrazek.jpg`.
```bash
obrazki () { 
	obrazy=$(grep -oPe "src.*?(jpg|png)" $temp_file | sed 's/src=\"//g')
```
