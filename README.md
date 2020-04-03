Instrukcja obsługi
===============================================

## Składnia 
Składnia: ```./skrypt.sh [OPCJA] [URL]```

## Opcje  
```-h``` - wyświetlenie pomocy i zakończenie programu.

## Działanie  
Skrypt umożliwia pobranie obrazków z rozszerzeniem `.jpg` oraz `.png` z zadanej strony <span>W</span>WW. Przed przystąpieniem do pobierania strony, skrypt sprawdza, czy została podana odpowiednia liczba argumentów (wymagany jest jeden adres URL lub opcja `-h`).
Kolejno, jeśl liczba argumentów jest poprawna, skrypt pobiera stronę o podanym adresie URL do pliku tymczasowego korzystając z programu `wget`.
