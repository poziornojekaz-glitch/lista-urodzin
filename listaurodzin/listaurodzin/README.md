# 🎂 Lista Urodzin (Flutter App)

Kompletna, lekka i w 100% lokalna aplikacja do zarządzania listą urodzin oraz powiadomieniami w telefonie (bez konieczności używania serwerów zewnętrznych takich jak Firebase czy Supabase).

---

## ✨ Funkcje aplikacji

1. **Zarządzanie urodzinami:**
   * Dodawanie i edycja osób z datą urodzin.
   * Obsługa opcjonalnego roku urodzenia (z możliwością ukrycia roku).
   * Blokada duplikatów o tym samym imieniu i dacie.
   * Inteligentne wyróżnianie dat:
     * 🔴 **Czerwony:** urodziny dzisiaj lub jutro.
     * 🔵 **Niebieski:** najbliższe nadchodzące wydarzenie.
   * Kalkulator wieku z poprawną odmianą gramatyczną (PL, EN, DE, RU).

2. **Lokalne powiadomienia (Awesome Notifications):**
   * Przypomnienia w dniu urodzin (domyślnie o 9:00).
   * Przypomnienia dzień wcześniej (domyślnie o 18:00).
   * Możliwość wyciszenia powiadomień dla pojedynczej osoby (checkbox przy nazwisku).
   * Roczne powtarzanie alarmów (`NotificationCalendar.repeats: true`).

3. **Wielojęzyczność:**
   * Pełne wsparcie dla 4 języków: **Polski 🇵🇱**, **Angielski 🇬🇧**, **Niemiecki 🇩🇪**, **Rosyjski 🇷🇺**.

4. **Udostępnianie listy:**
   * Zaznaczanie osób i eksport listy przez systemowe menu telefonu (`Share.share`).

5. **Trwały zapis offline:**
   * Dane zapisywane w telefonie za pomocą `shared_preferences` – nie znikną po wyłączeniu aplikacji ani po restarcie telefonu.

---

## 🚀 Jak uruchomić i skompilować aplikację

### 1. Otwórz projekt w Antigravity
Wybierz w górnym menu: **Plik ➔ Otwórz folder...** (lub `Ctrl+K Ctrl+O`) i wskaż folder:
`C:\Users\Kazach\.gemini\antigravity\scratch\listaurodzin`

### 2. Pobierz pakiety (w terminalu):
```bash
flutter pub get
```

### 3. Uruchom aplikację na telefonie:
```bash
flutter run
```

### 4. Zbuduj plik instalacyjny APK:
```bash
flutter build apk --release
```
Gotowy plik APK znajdziesz w folderze:
`build/app/outputs/flutter-apk/app-release.apk`
