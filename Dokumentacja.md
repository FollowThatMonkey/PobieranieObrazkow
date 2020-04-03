Dokumentacja skryptu
====================

## Struktura działania  
1. Skrypt sprawdza czy podana została opcja `-h`
   * Jeśli tak, to skrypt wyświetla pomoc i kończy działanie
2. Skrypt sprawdza czy została podana odpowiednia liczba argumentów (wymagany jeden argument - strona <span>WWW</span>).
   * Jeśli podana została błędna liczba argumentów, to skrypt wyświetla komunikat błędu i kończy działanie.
3. Skrypt pobiera przy użyciu programu `wget` zadaną stronę <span>WWW</span> do pliku tymczasowego.
   * Jeśli pobieranie nie powiedzie się, to skrypt wyświetla komunikat błędu i kończy działanie.
4. Skrypt przy użyciu programu `grep` wyszukuje znaczniki `<img src="obrazek.png">` lub `<img src="obrazek.jpg">` i przypisuje wyszukane linie do zmiennej.
5. Skrypt dopasowuje odpowiednio sposób podanej ścieżki tak, aby pobrać dany obrazek (w tym celu wykorzystano programy `grep` oraz `sed`).
6. Skrypt pobiera znalezione obrazki używając programu `wget`.
7. Po zakończeniu pobierania wszystkich obrazków, program usuwa plik tymczasowy komendą `rm`.

## Analiza kodu skryptu
1. Utworzenie niezbędnych do dalszego działania zmiennych
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

3. Sprawdzenie czy podany został jeden adres <span>WWW</span>. Jeśli nie, to skrypt wyświetla komunikat błędu i kończy działanie. W przeciwnym wypadku do zmiennej `url` zostaje przypisany pierwszy argument skryptu i zostają wywłoane funkcje: `pobierz`, `obrazki` oraz `usun`.
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