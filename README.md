# 日本語 Nihongo Manzil

[![Flutter](https://img.shields.io/badge/Flutter-3.3%2B-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Platform](https://img.shields.io/badge/platform-Android%20%7C%20iOS-3DDC84)](#-ishga-tushirish)
[![Architecture](https://img.shields.io/badge/architecture-Clean%20Architecture-6E56CF)](#%EF%B8%8F-arxitektura)
[![SRS](https://img.shields.io/badge/SRS-SM--2-orange)](#-sm-2--miyangiz-bilan-muzokara)
[![License](https://img.shields.io/badge/license-MIT-brightgreen)](#-litsenziya)

**Manzil — yapon tiliga.** Minna no Nihongo darslik strukturasi asosida qurilgan, Clean Architecture bilan yozilgan Flutter ilovasi. Har bir dars quruq "o'qib-yodlash" emas — lug'atdan tortib erkin gapirishgacha 7 bosqichli yo'l, so'zlarni miyangiz unutmasdan oldin qayta eslatib turadigan SM-2 algoritmi, va bilim bo'shliqlarini ochib tashlaydigan checkpoint imtihonlari bilan quriladi.

> あ、い、う、え、お — birinchi harfdan N5 gacha, bitta ilova ichida.

### Mundarija

[Nima uchun qiziqarli](#-nima-uchun-qiziqarli) · [SM-2](#-sm-2--miyangiz-bilan-muzokara) · [Arxitektura](#%EF%B8%8F-arxitektura) · [Ma'lumotlar bazasi](#-malumotlar-bazasi) · [Kontent formati](#-o%CA%BBz-kontentingizni-qo%CA%BBshish) · [Mualliflik huquqi](#%EF%B8%8F-muhim-mualliflik-huquqi) · [Ishga tushirish](#-ishga-tushirish) · [Release](#-release-build) · [Texnologiyalar](#-texnologiyalar) · [TODO](#%EF%B8%8F-keyingi-qadamlar-todo) · [Litsenziya](#-litsenziya)

## ✨ Nima uchun qiziqarli

Bu oddiy "flashcard ilova" emas. Har bir mashq turi tilni boshqa burchakdan ushlaydi:

| # | Bosqich | Nima sodir bo'ladi |
|---|---|---|
| 1 | 📖 Lug'atni tanishtirish | Yangi so'zlar birinchi marta ko'rsatiladi |
| 2 | 🔁 Faol mashq (SRS) | SM-2 algoritmi so'zni "unutish chegarasida" qayta so'raydi |
| 3 | 📐 Grammatikani tushuntirish | Qoida + misollar |
| 4 | ✏️ Tuzilmani mustahkamlash | Bo'shliqni to'ldirish, ko'p tanlovli savollar |
| 5 | 🔀 Aralashtirilgan mashq | So'zlarni to'g'ri tartibga terish |
| 6 | 💬 Erkin ishlatish | Ochiq savollarga o'z so'zi bilan javob |
| 7 | 🧩 Integratsiya | Hammasi birga — murakkabroq stsenariylar |

7-bosqichdan keyin **Quiz** (8-10 savol, o'tish balli 70%) kutib turadi. Ba'zi darslardan keyin esa **Checkpoint** — bir nechta darsni birlashtirgan, bloklovchi imtihon: o'tmasangiz, keyingi darsga yo'l yopiq.

Buning ustiga:

- 🗣️ **Speaking mashqi** — mikrofonga gapirasiz, ilova Levenshtein masofasiga asoslangan fonetik moslik ballini chiqaradi (offline, hech qanday tashqi API'siz)
- ✍️ **Writing mashqi** — yozma mashqlar alohida oqim sifatida
- 🎧 **Listening mashqi** — Text-to-Speech orqali eshitib tushunish
- 🎯 **Targeted practice** — sizning zaif nuqtalaringizni (`GetWeakPointsUsecase`) topib, aynan o'shalarga qaratilgan mashq generatsiya qiladi
- 📝 **Mistake log** — har bir xato kuzatiladi, tasodifan emas
- 🧭 **Placement test** — birinchi marta kirganda darajangizni aniqlaydi
- 📊 **Statistika va profil** — o'rganish faoliyati, quiz natijalari, umumiy progress

Pastki navigatsiya 5 bo'limdan iborat: **Bosh sahifa · Darslar · Mashq · Statistika · Profil** — va har biri `IndexedStack` bilan saqlanadi, ya'ni tab almashtirganingizda hech qanday scroll yoki state yo'qolmaydi.

## 🧠 SM-2 — miyangiz bilan muzokara

Bu ilovaning yuragi. 1987 yilda Piotr Wozniak ishlab chiqqan, Anki kabi ilovalarni mashhur qilgan algoritm — sizga qiyin kelgan so'zni tez-tez, oson kelganini kamdan-kam ko'rsatadi. Har javobdan keyin `ease factor` va interval qayta hisoblanadi (`lib/core/srs/sm2_algorithm.dart`), va bu 73 qatorlik sof Dart kod — hech qanday tarmoq, hech qanday bog'liqlik, faqat matematika. Unit test bilan tasdiqlangan.

## 🏗️ Arxitektura

Clean Architecture — uch qatlam, bitta qoida: **`presentation` faqat `domain`ni biladi, `domain` hech narsani (na Flutter, na SQLite) bilmaydi, `data` esa `domain` interfeyslarini implement qiladi.** Shu tufayli SQLite'ni ertaga Isar'ga yoki bulutli sinxronizatsiyaga almashtirish — bitta qatlamni almashtirish, hammasini qayta yozish emas.

```
lib/
  domain/             — biznes-logika, sof Dart
    entities/               Lesson, Vocabulary, GrammarPoint, PracticeItem,
                             SrsState, GrammarSrsState, Checkpoint, MistakeLogEntry,
                             PlacementTest, SpeakingItem, WritingPracticeItem, UserStats
    repositories/            9 ta abstrakt interfeys
    usecases/                GetLessons, AdvanceLessonStage, SubmitLessonQuiz,
                              ReviewFlashcard, ReviewGrammar, EvaluateCheckpoint,
                              GenerateTargetedPractice, GetWeakPoints,
                              PlacementTest, RecordStudyActivity

  data/               — SQLite bilan ishlaydigan haqiqiy qatlam
    repositories/            9 ta *_impl.dart
    datasources/             SeedDataLoader, JsonLessonLoader (JSON → domain)

  core/
    srs/                     SM-2 algoritmi (sof Dart, test qilingan)
    utils/                   PhoneticMatcher (Levenshtein-asosli talaffuz solishtirish)
    database/                DatabaseHelper (sxema, migratsiya)
    constants/               AppColors, AppTypography

  presentation/
    screens/                 16 ta ekran: onboarding, placement test, home,
                              lessons list, lesson, flashcard, grammar, practice,
                              targeted practice, quiz, checkpoint, practice hub,
                              speaking, writing, listening, stats, profile
    providers/                Riverpod provider'lar (repository + usecase + state)
```

**~4500 qator** presentation kodi, 9 ta domain repository, 10 ta usecase — bu allaqachon "demo" emas, to'liq ishlaydigan ilova skeleti.

## 🗄️ Ma'lumotlar bazasi

Hamma narsa qurilmada, offline saqlanadi — `sqflite` ustida **17 ta jadval** (`lib/core/database/database_helper.dart`): darslar, lug'at, grammatika, mashq elementlari, quiz savollari, checkpoint va uning natijalari, foydalanuvchi progressi, SRS holati (lug'at *va* grammatika uchun alohida-alohida), statistika, xatolar jurnali, speaking/writing mashqlari va urinishlar, placement test savol-natijalari. Internet yo'q, sinxronizatsiya yo'q — telefoningizdan chiqmaydi.

## 📥 O'z kontentingizni qo'shish

Sozlamalar → Kontent import orqali JSON yuklaysiz. Format shunday ko'rinadi (`assets/sample_data/lesson_template.json`dan qisqartirilgan):

```json
{
  "lesson": { "title": "Namuna dars sarlavhasi", "order_index": 3, "book": 1 },
  "vocabulary": [
    { "kanji": "食べます", "kana": "たべます", "romaji": "tabemasu",
      "translation_uz": "yeyman", "example_sentence": "わたしは ごはんを たべます。" }
  ],
  "grammar": [
    { "title": "СУЩ を ГЛАГ", "explanation": "を zarrachasi to'g'ridan-to'g'ri to'ldiruvchini ko'rsatadi.",
      "examples": [{ "jp": "ごはんを たべます。", "translation": "Ovqat yeyman." }] }
  ],
  "practice_items": [
    { "stage": 4, "type": "fillBlank",
      "content": { "sentence": "ごはん＿ たべます。" }, "correct_answer": "を" }
  ],
  "quiz_questions": [
    { "question": "「食べます」ning ma'nosi?",
      "options": ["ichaman", "yeyman", "ko'raman", "yozaman"], "correct_option_index": 1 }
  ]
}
```

`JsonLessonLoader` bu faylni domain entity'larga aylantiradi — kanji, kana, romaji, ikki tilga tarjima, misol gap, har xil turdagi mashq (`fillBlank`, `multipleChoice`, `rearrange`, `openEnded`) va quiz savollari bir joyda.

## ⚠️ Muhim: mualliflik huquqi

Minna no Nihongo — 3A Corporation nashri. Bu repoda **darslik matni yo'q**. `assets/sample_data/` ichidagi kontent (10 ta to'liq dars + shablon) butunlay o'zim yozgan, formatga mos namuna — haqiqiy darslikdan olinmagan. Real foydalanish uchun Sozlamalar → Kontent import orqali o'z (qonuniy) darslik nusxangizdan JSON tayyorlab yuklaysiz (shablon: `assets/sample_data/lesson_template.json`).

## 🚀 Ishga tushirish

Talab qilinadi: Flutter SDK 3.3+ ([o'rnatish](https://docs.flutter.dev/get-started/install))

```bash
flutter pub get
flutter run
```

Testlarni ishga tushirish:

```bash
flutter test
```

## 📦 Release build

```bash
# Android
flutter build apk --release
# Chiqadi: build/app/outputs/flutter-apk/app-release.apk

# iOS (faqat macOS + Xcode kerak)
flutter build ipa --release
```

Yoki qo'lni ho'llamang: repo `v*` tegi bilan push qilinganda, `.github/workflows/release.yml` avtomatik Android APK'ni build qilib, GitHub Release'ga yopishtirib qo'yadi.

```bash
git tag v1.0.0
git push origin v1.0.0
```

## 🧰 Texnologiyalar

`flutter_riverpod` (state) · `sqflite` (lokal baza) · `just_audio` + `flutter_tts` (talaffuz va eshitish) · `file_picker` (kontent import) · `google_fonts`, `percent_indicator` (UI)

## 🗺️ Keyingi qadamlar (TODO)

- [ ] `ContentImportRepository` uchun haqiqiy parser — hozir Sozlamalar ekranida placeholder
- [ ] Speaking/Listening ekranlarida audio fayllarni to'liq bog'lash
- [ ] `flutter analyze` bo'yicha to'liq statik tekshiruv (birinchi mahalliy ishga tushirishda tekshiring)
- [ ] Ko'proq dars kontenti (hozir 10 ta namunaviy dars bor)

## 📄 Litsenziya

Dastur kodi — MIT. Minna no Nihongo kontenti alohida mualliflik huquqiga ega va bu litsenziya qamrovidan tashqarida.

---

がんばって！ 🎌 — Omad tilaymiz, yapon tili sari yo'lingizda.
