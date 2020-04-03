Instrukcja obsługi skryptu
==========================

## Składnia 
Składnia: `./skrypt.sh [OPCJA] [URL]`

## Opcje  
`-h` - wyświetlenie pomocy i zakończenie programu.

## Działanie  
Skrypt umożliwia pobranie obrazków z rozszerzeniem `.jpg` oraz `.png` z zadanej strony <span>WWW</span>. Przed przystąpieniem do pobierania strony, skrypt sprawdza, czy została podana odpowiednia liczba argumentów (wymagany jest jeden adres URL lub opcja `-h`).
Kolejno, jeśl liczba argumentów jest poprawna, skrypt pobiera stronę o podanym adresie URL do pliku tymczasowego korzystając z programu `wget`. Jeśli pobieranie zakończy się porażką, to skrypt usuwa plik tymczasowy, wypisuje błąd oraz kończy działanie. W przeciwnym przypadku skrypt wyszukuje znaczniki `<img src="obrazek.png">` lub `<img src="obrazek.jpg">` i przy pomocy programu `wget` pobiera zawarte w nich obrazki.
