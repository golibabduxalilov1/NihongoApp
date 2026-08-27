# Nihongo Manzil

Minna no Nihongo darslik strukturasi asosida qurilgan, Clean Architecture bilan yozilgan Flutter ilovasi. Har bir dars 7 bosqichdan iborat (lug'at → grammatika → nazorat qilingan mashq → erkin ishlatish → integratsiya), SM-2 spaced repetition algoritmi bilan lug'at takrorlashni boshqaradi va har necha darsdan keyin bloklovchi checkpoint imtihoni beradi.

## Holat

Bu repo quyidagilarni o'z ichiga oladi:

- To'liq Clean Architecture (domain / data / presentation)
- Ishlaydigan SM-2 SRS algoritmi (unit test bilan tasdiqlangan)
- SQLite sxemasi va barcha repository implementatsiyalari
- 2 ta to'liq to'ldirilgan namunaviy dars + 1 checkpoint (demo/test uchun, litsenziyasiz)
- 10 ta ekran: bosh sahifa, dars, flashcard, grammatika, mashq (4 turi), quiz, checkpoint, statistika, sozlamalar

## Muhim: mualliflik huquqi

Minna no Nihongo — 3A Corporation nashri. Bu repoda **darslik matni yo'q**. `assets/sample_data/` ichidagi kontent butunlay o'zim yozgan, formatga mos namuna — haqiqiy darslikdan olinmagan. Real foydalanish uchun Sozlamalar → Kontent import orqali o'z (qonuniy) darslik nusxangizdan JSON tayyorlab yuklaysiz (shablon: `assets/sample_data/lesson_template.json`).

## Ishga tushirish

Talab qilinadi: Flutter SDK 3.3+ ([o'rnatish](https://docs.flutter.dev/get-started/install))

```bash
flutter pub get
flutter run
```

Testlarni ishga tushirish:

```bash
flutter test
```

## Release build

```bash
# Android
flutter build apk --release
# Chiqadi: build/app/outputs/flutter-apk/app-release.apk

# iOS (faqat macOS + Xcode kerak)
flutter build ipa --release
```

GitHub Release'ga qo'lda yuklash: repo sahifasida **Releases → Draft a new release**, tag qo'ying (masalan `v1.0.0`), `.apk` faylni biriktiring, **Publish**.

## Arxitektura

```
lib/
  domain/     — biznes-logika, hech qanday Flutter/SQLite bog'liqligisiz
    entities/       Lesson, VocabularyItem, GrammarPoint, PracticeItem, SrsState, Checkpoint
    repositories/   Abstrakt interfeyslar
    usecases/       GetLessons, AdvanceLessonStage, SubmitLessonQuiz, ReviewFlashcard, EvaluateCheckpoint
  data/       — SQLite bilan ishlaydigan haqiqiy implementatsiya
    repositories/   *_impl.dart fayllar
    datasources/    SeedDataLoader (demo kontent)
  core/
    srs/            SM-2 algoritmi (sof Dart, test qilingan)
    database/       DatabaseHelper (sxema, migratsiya)
    constants/      AppColors
  presentation/
    screens/        10 ta ekran, bosqichlar bo'yicha
    providers/      Riverpod provider'lar (repository + usecase + state)
```

Qatlamlar orasidagi qoida: `presentation` faqat `domain`ni biladi, `domain` hech narsani (na Flutter, na SQLite) bilmaydi, `data` esa `domain` interfeyslarini implement qiladi. Bu SQLite'ni keyinchalik boshqa bazaga (masalan Isar yoki bulutli sinxronizatsiya) almashtirishni osonlashtiradi.

## Dars strukturasi (7 bosqich)

| # | Bosqich | Ekran |
|---|---|---|
| 1 | Lug'atni tanishtirish | `FlashcardScreen` (isIntroMode: true) |
| 2 | Lug'atni faol mashq qilish (SRS) | `FlashcardScreen` (isIntroMode: false) |
| 3 | Grammatikani tushuntirish | `GrammarScreen` |
| 4 | Tuzilmani mustahkamlash | `PracticeScreen` (fillBlank, multipleChoice) |
| 5 | Aralashtirilgan mashq | `PracticeScreen` (rearrange) |
| 6 | Erkin ishlatish | `PracticeScreen` (openEnded) |
| 7 | Integratsiya | `PracticeScreen` (openEnded, murakkabroq) |

7-bosqichdan keyin `QuizScreen` (8-10 savol, o'tish balli 70%) ochiladi. Agar shu darsdan keyin checkpoint belgilangan bo'lsa (`checkpoints` jadvali), foydalanuvchi avtomatik `CheckpointScreen`ga yo'naltiriladi.

## Keyingi qadamlar (TODO)

- [ ] Haqiqiy kontent-import parser (`ContentImportRepository`) — hozir Sozlamalar ekranida placeholder
- [ ] Audio fayllarni `just_audio` bilan bog'lash (hozir `audio_path` maydoni bor, lekin pleer ulanmagan)
- [ ] `flutter_lints` bo'yicha to'liq statik tekshiruv (`flutter analyze`) — bu repo Flutter SDK'siz muhitda yozilgan, shuning uchun mahalliy kompyuteringizda birinchi marta ishga tushirishda tekshiring
- [ ] GitHub Actions workflow (`.github/workflows/release.yml`) — avtomatik APK build

## Litsenziya

Dastur kodi — MIT. Minna no Nihongo kontenti alohida mualliflik huquqiga ega va bu litsenziya qamrovidan tashqarida.
