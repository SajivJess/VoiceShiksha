class Letter {
  final String character;
  final String hint;
  final String pronunciation;
  final String audioFile;

  const Letter({
    required this.character,
    required this.hint,
    required this.pronunciation,
    required this.audioFile,
  });
}

class LetterData {
  static const List<Letter> hindiVowels = [
    Letter(
      character: "अ",
      hint: 'Say "A" like in "Apple"',
      pronunciation: "A",
      audioFile: "A.wav",
    ),
    Letter(
      character: "आ",
      hint: 'Say "Aa" like in "Arm"',
      pronunciation: "Aaa",
      audioFile: "Aaa.wav",
    ),
    Letter(
      character: "इ",
      hint: 'Say "I" like in "Ink"',
      pronunciation: "I",
      audioFile: "I.wav",
    ),
    Letter(
      character: "ई",
      hint: 'Say "Ee" like in "See"',
      pronunciation: "Ee",
      audioFile: "Ee.wav",
    ),
    Letter(
      character: "उ",
      hint: 'Say "U" like in "Put"',
      pronunciation: "U",
      audioFile: "U.wav",
    ),
    Letter(
      character: "ऊ",
      hint: 'Say "Oo" like in "School"',
      pronunciation: "Uu",
      audioFile: "Uu.wav",
    ),
    Letter(
      character: "ए",
      hint: 'Say "E" like in "Red"',
      pronunciation: "E",
      audioFile: "E.wav",
    ),
    Letter(
      character: "ऐ",
      hint: 'Say "Ai" like in "Air"',
      pronunciation: "Ai",
      audioFile: "Ai.wav",
    ),
    Letter(
      character: "ओ",
      hint: 'Say "O" like in "Go"',
      pronunciation: "O",
      audioFile: "O.wav",
    ),
    Letter(
      character: "औ",
      hint: 'Say "Au" like in "Cow"',
      pronunciation: "Au",
      audioFile: "Au.wav",
    ),
  ];
}