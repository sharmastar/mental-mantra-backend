enum EmotionalState {
  fearAnxiety('Fear & Anxiety', '🌊', 'When worry clouds your mind'),
  angerControl('Anger & Control', '🔥', 'When frustration rises within'),
  lowMotivation('Low Motivation', '⚡', 'When energy feels distant'),
  griefSadness('Grief & Sadness', '💧', 'When the heart feels heavy'),
  confusionDoubt('Confusion & Doubt', '🌀', 'When the path is unclear'),
  peaceCalm('Peace & Calm', '🕊️', 'When you seek serenity'),
  selfWorth('Self-Worth', '💎', 'When you need to remember your value'),
  detachment('Detachment & Letting Go', '🍂', 'When you need to release control');

  final String label;
  final String emoji;
  final String description;
  const EmotionalState(this.label, this.emoji, this.description);
}

class GitaSloka {
  final String sanskrit;
  final String transliteration;
  final String meaning;
  final String lesson;
  final String chapter;
  final int verse;
  final EmotionalState state;
  final String? audioUrl;
  final String? context;

  const GitaSloka({
    required this.sanskrit,
    required this.transliteration,
    required this.meaning,
    required this.lesson,
    required this.chapter,
    required this.verse,
    required this.state,
    this.audioUrl,
    this.context,
  });
}

final gitaCatalog = {
  EmotionalState.fearAnxiety: [
    const GitaSloka(
      sanskrit: 'भगवद्गीता २.४७\nमा फलेषु कदाचन',
      transliteration: 'Mā phaleṣu kadācana',
      meaning: 'You have a right to perform your prescribed duties, but you are not entitled to the fruits of your actions.',
      lesson: 'Focus on what you can control — your effort, not the outcome. Anxiety dissolves when we release attachment to results.',
      chapter: 'Chapter 2',
      verse: 47,
      state: EmotionalState.fearAnxiety,
      context: 'Krishna teaches Arjuna about detached action on the battlefield — a lesson for when fear of failure paralyzes us.',
    ),
    const GitaSloka(
      sanskrit: 'भगवद्गीता ६.५\nउद्धरेदात्मनात्मानम्',
      transliteration: 'Uddhared ātmanātmānam',
      meaning: 'Lift yourself up by yourself. Do not let yourself sink down. For you alone are your own friend, and you alone are your own enemy.',
      lesson: 'You have the power to lift yourself out of fear. The same mind that creates worry can create courage.',
      chapter: 'Chapter 6',
      verse: 5,
      state: EmotionalState.fearAnxiety,
    ),
    const GitaSloka(
      sanskrit: 'भगवद्गीता १८.५८\nमच्चित्तः सर्वदुर्गाणि',
      transliteration: 'Maccittaḥ sarva-durgāṇi',
      meaning: 'If you fix your mind on Me, you will overcome all obstacles by My grace.',
      lesson: 'When fear feels overwhelming, anchoring your mind in a higher purpose — whatever that means to you — gives you strength to cross every difficulty.',
      chapter: 'Chapter 18',
      verse: 58,
      state: EmotionalState.fearAnxiety,
    ),
  ],
  EmotionalState.angerControl: [
    const GitaSloka(
      sanskrit: 'भगवद्गीता २.६३\nक्रोधाद्भवति सम्मोहः',
      transliteration: 'Krodhād bhavati sammohaḥ',
      meaning: 'From anger comes delusion, and from delusion loss of memory. From loss of memory comes the destruction of discrimination, and from destruction of discrimination one perishes.',
      lesson: 'Anger clouds your judgment. When you feel rage rising, pause and breathe — reacting in anger only leads to decisions you may regret.',
      chapter: 'Chapter 2',
      verse: 63,
      state: EmotionalState.angerControl,
    ),
    const GitaSloka(
      sanskrit: 'भगवद्गीता १६.२१\nत्रिविधं नरकस्येदम्',
      transliteration: 'Trividhaṁ narakasyedam',
      meaning: 'There are three gates to hell — lust, anger, and greed. Every wise person should abandon these, for they lead to the ruin of the soul.',
      lesson: 'Anger is one of the three gateways to suffering. Recognizing it rising is the first step to choosing a different path.',
      chapter: 'Chapter 16',
      verse: 21,
      state: EmotionalState.angerControl,
    ),
    const GitaSloka(
      sanskrit: 'भगवद्गीता ५.२३\nशक्नोतीहैव यः सोढुम्',
      transliteration: 'Śaknotīhaiva yaḥ soḍhum',
      meaning: 'Before giving up this body, if one is able to tolerate the urges of anger and desires, they are well-situated and happy in this world.',
      lesson: 'The ability to pause before reacting is a superpower. Each moment you choose calm over anger, you build inner strength.',
      chapter: 'Chapter 5',
      verse: 23,
      state: EmotionalState.angerControl,
    ),
  ],
  EmotionalState.lowMotivation: [
    const GitaSloka(
      sanskrit: 'भगवद्गीता २.४०\nस्वल्पमप्यस्य धर्मस्य',
      transliteration: 'Svalpam apy asya dharmasya',
      meaning: 'There is no loss of effort on this path. Even a little practice of this discipline protects one from great fear.',
      lesson: 'Even one small step forward matters. You don\'t need to do everything at once — just start with something tiny.',
      chapter: 'Chapter 2',
      verse: 40,
      state: EmotionalState.lowMotivation,
    ),
    const GitaSloka(
      sanskrit: 'भगवद्गीता ३.८\nनियतं कुरु कर्म त्वम्',
      transliteration: 'Niyataṁ kuru karma tvam',
      meaning: 'Perform your prescribed duties, for action is superior to inaction. Even the maintenance of your body would not be possible without action.',
      lesson: 'Action itself creates momentum. When you don\'t feel like doing anything, start with something small — movement generates energy.',
      chapter: 'Chapter 3',
      verse: 8,
      state: EmotionalState.lowMotivation,
    ),
  ],
  EmotionalState.griefSadness: [
    const GitaSloka(
      sanskrit: 'भगवद्गीता २.१४\nमात्रास्पर्शास्तु कौन्तेय',
      transliteration: 'Mātrā-sparśās tu kaunteya',
      meaning: 'The contacts of senses with their objects cause sensations of heat and cold, pleasure and pain. They come and go like seasons. Bear them patiently.',
      lesson: 'Pain is temporary. Like winter passes into spring, grief too shall pass. You are strong enough to weather this season.',
      chapter: 'Chapter 2',
      verse: 14,
      state: EmotionalState.griefSadness,
    ),
    const GitaSloka(
      sanskrit: 'भगवद्गीता २.२०\nन जायते म्रियते वा कदाचित्',
      transliteration: 'Na jāyate mriyate vā kadācit',
      meaning: 'The soul is neither born nor does it ever die. It is eternal, ever-existing, and primeval. It is not slain when the body is slain.',
      lesson: 'What you truly are transcends this moment of pain. The essence of who you love and who you are continues beyond change.',
      chapter: 'Chapter 2',
      verse: 20,
      state: EmotionalState.griefSadness,
    ),
  ],
  EmotionalState.confusionDoubt: [
    const GitaSloka(
      sanskrit: 'भगवद्गीता ४.१८\nगहना कर्मणो गतिः',
      transliteration: 'Gahanā karmaṇo gatiḥ',
      meaning: 'The ways of action are mysterious. One who sees inaction in action and action in inaction is wise among all.',
      lesson: 'Not all that seems productive is progress, and not all rest is wasted time. Trust that clarity emerges when you stop forcing it.',
      chapter: 'Chapter 4',
      verse: 18,
      state: EmotionalState.confusionDoubt,
    ),
    const GitaSloka(
      sanskrit: 'भगवद्गीता १८.६३\nइति ते ज्ञानमाख्यातम्',
      transliteration: 'Iti te jñānam ākhyātam',
      meaning: 'I have shared with you this knowledge. Reflect on it fully, and then do as you wish.',
      lesson: 'True wisdom doesn\'t force a decision — it provides clarity and then trusts you to choose. You have the wisdom within you.',
      chapter: 'Chapter 18',
      verse: 63,
      state: EmotionalState.confusionDoubt,
    ),
  ],
  EmotionalState.peaceCalm: [
    const GitaSloka(
      sanskrit: 'भगवद्गीता ६.२९\nसर्वभूतस्थमात्मानम्',
      transliteration: 'Sarva-bhūta-stham ātmānam',
      meaning: 'One who sees Me in all beings and all beings in Me experiences true peace.',
      lesson: 'Peace comes when you feel connected to everything around you. You are not separate — you are part of something beautiful.',
      chapter: 'Chapter 6',
      verse: 29,
      state: EmotionalState.peaceCalm,
    ),
    const GitaSloka(
      sanskrit: 'भगवद्गीता २.७०\nआपूर्यमाणमचलप्रतिष्ठम्',
      transliteration: 'Āpūryamāṇam acala-pratiṣṭham',
      meaning: 'Like the ocean remains undisturbed even as rivers flow into it, the wise remain unshaken amidst desires.',
      lesson: 'True calm is not the absence of noise, but stillness within it. You can be the ocean — vast, deep, and undisturbed.',
      chapter: 'Chapter 2',
      verse: 70,
      state: EmotionalState.peaceCalm,
    ),
  ],
  EmotionalState.selfWorth: [
    const GitaSloka(
      sanskrit: 'भगवद्गीता १०.२०\nअहमात्मा गुडाकेश',
      transliteration: 'Aham ātmā guḍākeśa',
      meaning: 'I am the Self, Arjuna, seated in the heart of all beings. I am the beginning, the middle, and the end of all existence.',
      lesson: 'Your worth is not earned — it is inherent. The same divine essence that moves the universe lives within you.',
      chapter: 'Chapter 10',
      verse: 20,
      state: EmotionalState.selfWorth,
    ),
    const GitaSloka(
      sanskrit: 'भगवद्गीता ६.३२\nआत्मौपम्येन सर्वत्र',
      transliteration: 'Ātmaupamyena sarvatra',
      meaning: 'One who sees the self in all beings and all beings in the self, seeing everyone equally, lives in the highest state of yoga.',
      lesson: 'See yourself with the same compassion you offer others. You deserve the kindness you so freely give.',
      chapter: 'Chapter 6',
      verse: 32,
      state: EmotionalState.selfWorth,
    ),
  ],
  EmotionalState.detachment: [
    const GitaSloka(
      sanskrit: 'भगवद्गीता ३.१९\nतस्मादसक्तः सततम्',
      transliteration: 'Tasmād asaktaḥ satatam',
      meaning: 'Therefore, perform your duties without attachment. By working without attachment, one attains the supreme.',
      lesson: 'Do what you can, then release the outcome. Clinging to results creates suffering — letting go brings freedom.',
      chapter: 'Chapter 3',
      verse: 19,
      state: EmotionalState.detachment,
    ),
    const GitaSloka(
      sanskrit: 'भगवद्गीता १५.७\nममैवांशो जीवलोके',
      transliteration: 'Mamaivāṁśo jīva-loke',
      meaning: 'The eternal living entity is an eternal fragment of Me. In this world, they struggle with the mind and senses.',
      lesson: 'You are a fragment of something infinite. The struggles you face are temporary — your essence remains untouched.',
      chapter: 'Chapter 15',
      verse: 7,
      state: EmotionalState.detachment,
    ),
  ],
};

GitaSloka? getSlokaForEmotion(EmotionalState state) {
  final slokas = gitaCatalog[state];
  if (slokas == null || slokas.isEmpty) return null;
  return slokas[DateTime.now().day % slokas.length];
}

List<GitaSloka> getSlokasForEmotion(EmotionalState state) {
  return gitaCatalog[state] ?? [];
}
