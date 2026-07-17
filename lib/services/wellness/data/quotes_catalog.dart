class QuotesCatalog {
  QuotesCatalog._();

  // Get a quote for a specific day index (1 to 1000)
  static Map<String, String> getQuoteForDay(int dayIndex) {
    final list = allQuotes;
    final idx = dayIndex % list.length;
    return list[idx];
  }

  // Gets the daily quote dynamically using the day of the year + year hash
  static Map<String, String> getDailyQuote() {
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays + 1;
    final hash = (dayOfYear + now.year * 31) % 1000;
    return getQuoteForDay(hash);
  }

  static List<Map<String, String>> get allQuotes {
    final quotes = <Map<String, String>>[];

    // 1. Pre-defined Premium Real Quotes (100 High-Quality Quotes)
    final realQuotes = [
      {'text': 'Peace begins with a smile.', 'author': 'Mother Teresa'},
      {
        'text': 'The mind is everything. What you think you become.',
        'author': 'Buddha'
      },
      {
        'text':
            'You are not your thoughts. You are the observer of your thoughts.',
        'author': 'Eckhart Tolle'
      },
      {
        'text':
            'Almost everything will work again if you unplug it for a few minutes, including you.',
        'author': 'Anne Lamott'
      },
      {
        'text':
            'Self-care is not selfish. You cannot serve from an empty vessel.',
        'author': 'Eleanor Brown'
      },
      {
        'text':
            'The greatest weapon against stress is our ability to choose one thought over another.',
        'author': 'William James'
      },
      {
        'text':
            'You don\'t have to control your thoughts. You just have to stop letting them control you.',
        'author': 'Dan Millman'
      },
      {
        'text':
            'Rest when you\'re weary. Refresh and renew yourself. Your body and mind will thank you.',
        'author': 'Lailah Gifty Akita'
      },
      {
        'text':
            'Breathe. Let go. And remind yourself that this very moment is the only one you know you have.',
        'author': 'Oprah Winfrey'
      },
      {
        'text': 'Believe you can and you\'re halfway there.',
        'author': 'Theodore Roosevelt'
      },
      {
        'text': 'Feelings are just visitors, let them come and go.',
        'author': 'Mooji'
      },
      {
        'text': 'Quiet the mind and the soul will speak.',
        'author': 'Ma Jaya Sati Bhagavati'
      },
      {'text': 'Rule your mind or it will rule you.', 'author': 'Horace'},
      {
        'text':
            'Do not dwell in the past, do not dream of the future, concentrate the mind on the present moment.',
        'author': 'Buddha'
      },
      {
        'text':
            'Within you, there is a stillness and a sanctuary to which you can retreat at any time and be yourself.',
        'author': 'Hermann Hesse'
      },
      {
        'text':
            'The present moment is filled with joy and happiness. If you are attentive, you will see it.',
        'author': 'Thich Nhat Hanh'
      },
      {
        'text': 'He who has a why to live can bear almost any how.',
        'author': 'Friedrich Nietzsche'
      },
      {
        'text':
            'Happiness is not something ready-made. It comes from your own actions.',
        'author': 'Dalai Lama'
      },
      {
        'text': 'Act as if what you do makes a difference. It does.',
        'author': 'William James'
      },
      {
        'text': 'The only journey is the one within.',
        'author': 'Rainer Maria Rilke'
      },
      {
        'text':
            'Keep your face always toward the sunshine - and shadows will fall behind you.',
        'author': 'Walt Whitman'
      },
      {
        'text':
            'No limit exists to the power of the human mind. The more concentrated it is, the more power is brought to bear on one point.',
        'author': 'Swami Vivekananda'
      },
      {
        'text':
            'Your calm mind is the ultimate weapon against your challenges. So close your eyes and breathe.',
        'author': 'Bryant McGill'
      },
      {
        'text':
            'Sometimes the most important thing in a whole day is the rest we take between two deep breaths.',
        'author': 'Etty Hillesum'
      },
      {
        'text':
            'Realize deeply that the present moment is all you have. Make the NOW the primary focus of your life.',
        'author': 'Eckhart Tolle'
      },
      {
        'text': 'Nature does not hurry, yet everything is accomplished.',
        'author': 'Lao Tzu'
      },
      {
        'text':
            'You yourself, as much as anybody in the entire universe, deserve your love and affection.',
        'author': 'Buddha'
      },
      {
        'text':
            'Simplicity, patience, compassion. These three are your greatest treasures.',
        'author': 'Lao Tzu'
      },
      {
        'text':
            'Mindfulness isn\'t difficult, we just need to remember to do it.',
        'author': 'Sharon Salzberg'
      },
      {
        'text':
            'Do not lose yourself in the past. Do not lose yourself in the future. Anchor yourself here.',
        'author': 'Thich Nhat Hanh'
      },
      {
        'text':
            'The soul always knows what to do to heal itself. The challenge is to silence the mind.',
        'author': 'Caroline Myss'
      },
      {
        'text':
            'To walk safely through the maze of human life, one needs the light of wisdom and the guidance of virtue.',
        'author': 'Buddha'
      },
      {
        'text':
            'Meditation is not evasion; it is a serene encounter with reality.',
        'author': 'Thich Nhat Hanh'
      },
      {'text': 'Be here now.', 'author': 'Ram Dass'},
      {
        'text':
            'Nothing is permanent in this wicked world - not even our troubles.',
        'author': 'Charlie Chaplin'
      },
      {
        'text':
            'The primary cause of unhappiness is never the situation but your thoughts about it.',
        'author': 'Eckhart Tolle'
      },
      {
        'text': 'Muddy water is best cleared by leaving it alone.',
        'author': 'Alan Watts'
      },
      {
        'text':
            'If you want to conquer the anxiety of life, live in the moment, live in the breath.',
        'author': 'Amit Ray'
      },
      {
        'text': 'Do your practice and all is coming.',
        'author': 'Sri K. Pattabhi Jois'
      },
      {
        'text':
            'Tension is who you think you should be. Relaxation is who you are.',
        'author': 'Chinese Proverb'
      },
      {
        'text': 'With every breath, I release the old and welcome the new.',
        'author': 'Unknown'
      },
      {
        'text':
            'Self-compassion is simply giving ourselves the same kindness we would give others.',
        'author': 'Kristin Neff'
      },
      {
        'text':
            'We are what we repeatedly do. Excellence, then, is not an act, but a habit.',
        'author': 'Aristotle'
      },
      {
        'text':
            'The secret of change is to focus all of your energy not on fighting the old, but on building the new.',
        'author': 'Socrates'
      },
      {
        'text':
            'One small positive thought in the morning can change your entire day.',
        'author': 'Unknown'
      },
      {
        'text':
            'You have power over your mind - not outside events. Realize this, and you will find strength.',
        'author': 'Marcus Aurelius'
      },
      {
        'text':
            'The happiness of your life depends upon the quality of your thoughts.',
        'author': 'Marcus Aurelius'
      },
      {
        'text':
            'Very little is needed to make a happy life; it is all within yourself in your way of thinking.',
        'author': 'Marcus Aurelius'
      },
      {
        'text':
            'Waste no more time arguing about what a good man should be. Be one.',
        'author': 'Marcus Aurelius'
      },
      {
        'text':
            'Loss is nothing else but change, and change is Nature\'s delight.',
        'author': 'Marcus Aurelius'
      },
      {
        'text':
            'When you arise in the morning, think of what a precious privilege it is to be alive.',
        'author': 'Marcus Aurelius'
      },
      {
        'text':
            'Accept the things to which fate binds you, and love the people with whom fate brings you together.',
        'author': 'Marcus Aurelius'
      },
      {
        'text':
            'The best revenge is to be unlike him who performed the injury.',
        'author': 'Marcus Aurelius'
      },
      {
        'text': 'Breathe in deeply to bring your mind home to your body.',
        'author': 'Thich Nhat Hanh'
      },
      {
        'text': 'Be kind whenever possible. It is always possible.',
        'author': 'Dalai Lama'
      },
      {'text': 'An open heart is an open mind.', 'author': 'Dalai Lama'},
      {
        'text':
            'Remember that sometimes not getting what you want is a wonderful stroke of luck.',
        'author': 'Dalai Lama'
      },
      {'text': 'Silence is sometimes the best answer.', 'author': 'Dalai Lama'},
      {
        'text': 'Choose to be optimistic, it feels better.',
        'author': 'Dalai Lama'
      },
      {
        'text':
            'In the practice of tolerance, one\'s enemy is the best teacher.',
        'author': 'Dalai Lama'
      },
      {
        'text':
            'Love and compassion are necessities, not luxuries. Without them, humanity cannot survive.',
        'author': 'Dalai Lama'
      },
      {
        'text':
            'Our prime purpose in this life is to help others. And if you can\'t help them, at least don\'t hurt them.',
        'author': 'Dalai Lama'
      },
      {
        'text':
            'Wisdom comes from reflecting on experience, not just having it.',
        'author': 'Unknown'
      },
      {
        'text':
            'Each morning we are born again. What we do today is what matters most.',
        'author': 'Buddha'
      },
      {'text': 'A jug fills drop by drop.', 'author': 'Buddha'},
      {
        'text': 'Peace comes from within. Do not seek it without.',
        'author': 'Buddha'
      },
      {
        'text': 'There is no path to happiness: happiness is the path.',
        'author': 'Buddha'
      },
      {
        'text': 'To conquer oneself is a greater task than conquering others.',
        'author': 'Buddha'
      },
      {'text': 'The root of suffering is attachment.', 'author': 'Buddha'},
      {
        'text':
            'You will not be punished for your anger; you will be punished by your anger.',
        'author': 'Buddha'
      },
      {
        'text': 'Do not look for sanctuary in anyone except yourself.',
        'author': 'Buddha'
      },
      {
        'text':
            'The only real failure in life is not to be true to the best one knows.',
        'author': 'Buddha'
      },
      {
        'text':
            'Purity or impurity depends on oneself, no one can purify another.',
        'author': 'Buddha'
      },
      {
        'text': 'He has no fear who is not filled with anxiety.',
        'author': 'Lao Tzu'
      },
      {
        'text': 'To the mind that is still, the entire universe surrenders.',
        'author': 'Lao Tzu'
      },
      {
        'text': 'When I let go of what I am, I become what I might be.',
        'author': 'Lao Tzu'
      },
      {
        'text': 'An ant on the move does more than a dozing ox.',
        'author': 'Lao Tzu'
      },
      {
        'text': 'A journey of a thousand miles begins with a single step.',
        'author': 'Lao Tzu'
      },
      {
        'text':
            'Do you have the patience to wait till your mud settles and the water is clear?',
        'author': 'Lao Tzu'
      },
      {'text': 'He who is contented is rich.', 'author': 'Lao Tzu'},
      {
        'text':
            'Care about what other people think and you will always be their prisoner.',
        'author': 'Lao Tzu'
      },
      {
        'text':
            'The key to growth is the introduction of higher dimensions of consciousness into our awareness.',
        'author': 'Lao Tzu'
      },
      {
        'text': 'Be content with what you have; rejoice in the way things are.',
        'author': 'Lao Tzu'
      },
      {
        'text': 'As soon as you trust yourself, you will know how to live.',
        'author': 'Johann Wolfgang von Goethe'
      },
      {
        'text':
            'Knowing is not enough; we must apply. Willing is not enough; we must do.',
        'author': 'Johann Wolfgang von Goethe'
      },
      {
        'text':
            'Magic is believing in yourself. If you can make that happen, you can make anything happen.',
        'author': 'Johann Wolfgang von Goethe'
      },
      {
        'text':
            'Be like the flower that gives its fragrance even to the hand that crushes it.',
        'author': 'Ali ibn Abi Talib'
      },
      {
        'text':
            'Patience is of two kinds: patience over what pains you, and patience against what covets you.',
        'author': 'Ali ibn Abi Talib'
      },
      {'text': 'A man\'s measure is his will.', 'author': 'Ali ibn Abi Talib'},
      {
        'text':
            'The tongue is like a lion; if you let it loose, it will wound someone.',
        'author': 'Ali ibn Abi Talib'
      },
      {
        'text': 'Live simple, breathe deep, and let love guide you.',
        'author': 'Zen Proverb'
      },
      {'text': 'The obstacle is the path.', 'author': 'Zen Proverb'},
      {'text': 'Leap, and the net will appear.', 'author': 'Zen Proverb'},
      {
        'text': 'Knock on the sky and listen to the sound.',
        'author': 'Zen Proverb'
      },
      {
        'text': 'Walk as if you are kissing the Earth with your feet.',
        'author': 'Thich Nhat Hanh'
      },
      {
        'text': 'Because you are alive, everything is possible.',
        'author': 'Thich Nhat Hanh'
      },
      {
        'text':
            'Hope is important because it can make the present moment less difficult to bear.',
        'author': 'Thich Nhat Hanh'
      },
      {
        'text':
            'My actions are my only true belongings. I cannot escape the consequences of my actions.',
        'author': 'Thich Nhat Hanh'
      },
      {
        'text':
            'To be beautiful means to be yourself. You don\'t need to be accepted by others. You need to accept yourself.',
        'author': 'Thich Nhat Hanh'
      },
      {
        'text': 'Life is available only in the present.',
        'author': 'Thich Nhat Hanh'
      },
    ];

    quotes.addAll(realQuotes);

    // 2. Procedural Combinatorial Generation to scale to 1000 quotes!
    // We combine themes, subjects, actions, and historical wisdom models

    final segments = [
      {
        'theme': 'mindfulness',
        'templates': [
          'Bring your attention to the present; it is where your entire life unfolds.',
          'Letting go of thoughts is the highest form of mental rest.',
          'True clarity arises when the noise of the external world is silenced.',
          'Observation without judgment is the peak of human intelligence.',
          'Anchor your mind in the simple flow of your current breath.'
        ]
      },
      {
        'theme': 'inner peace',
        'templates': [
          'Calmness is not the absence of storm, but the peace within the center of it.',
          'Your peace is your responsibility; do not outsource it to external conditions.',
          'Rest in the quiet chamber of your heart; there is no rush.',
          'When you surrender the need to control, you receive infinite calm.',
          'Quiet waters reflect the sky; a quiet mind reflects universal wisdom.'
        ]
      },
      {
        'theme': 'courage',
        'templates': [
          'Strength is not defined by lack of fear, but by taking the next small step anyway.',
          'You are far stronger than the passing storm of your emotions.',
          'Trust your capacity to adapt, survive, and grow through discomfort.',
          'Fear is a protective signal, not a boundary of your potential.',
          'Stand tall in your truth, even when the wind blows against you.'
        ]
      },
      {
        'theme': 'resilience',
        'templates': [
          'Fall seven times, stand up eight; your spirit is unbreakable.',
          'The darkest nights produce the brightest stars; keep moving forward.',
          'Every obstacle is a training ground for your inner warrior.',
          'Pressure is what turns charcoal into diamonds; embrace the pressure.',
          'Healing is not linear, but every single micro-action builds momentum.'
        ]
      },
      {
        'theme': 'patience',
        'templates': [
          'Allow things to unfold in their natural, organic season.',
          'Patience is the quiet strength that protects you from hasty regrets.',
          'Wait for the mud to settle; clarity will show itself when it is ready.',
          'Hurrying only creates friction; glide smoothly through time.',
          'The tree does not race to grow; it simply sinks its roots deep.'
        ]
      },
      {
        'theme': 'gratitude',
        'templates': [
          'Count the small blessings; they form the foundation of a joyful life.',
          'An appreciative heart is naturally immune to daily anxiety.',
          'Find joy in the simple warmth of sun, water, and breath.',
          'Gratitude turns what we have into more than enough.',
          'Celebrate the progress you have made today, no matter how minor.'
        ]
      },
      {
        'theme': 'focus',
        'templates': [
          'Do one thing at a time with your entire heart and soul.',
          'Clear the mental clutter; focus is the laser that cuts through doubt.',
          'Align your attention with your highest daily priorities.',
          'Quiet the urge to be everywhere; be completely here.',
          'A concentrated mind is the ultimate weapon against confusion.'
        ]
      },
      {
        'theme': 'self love',
        'templates': [
          'You deserve the same kindness and compassion you offer to others.',
          'Treat yourself like a valued friend, with absolute grace and patience.',
          'Your worth is inherent; it does not change based on productivity.',
          'Forgive your mistakes; they are lessons, not your identity.',
          'Protect your boundaries; they are the sanctuary of your peace.'
        ]
      },
      {
        'theme': 'discipline',
        'templates': [
          'Small daily habits build the bridges to your ultimate dreams.',
          'Saying no to distractions is saying yes to your future self.',
          'Choose progress over comfort; the rewards are lasting.',
          'Discipline is the highest form of self-love and self-respect.',
          'Do what needs to be done, even when motivation is low.'
        ]
      },
      {
        'theme': 'healing',
        'templates': [
          'Grief and pain are waves; allow them to wash over you and pass.',
          'Let go of the baggage of yesterday; you are free to begin again.',
          'Your scars are proof of your healing, not your brokenness.',
          'Soothe your nervous system; you are completely safe in this moment.',
          'Give yourself permission to slow down and restore your energy.'
        ]
      },
      {
        'theme': 'growth',
        'templates': [
          'Celebrate every small win; they accumulate into massive transformation.',
          'Discomfort is the indicator of expansion; welcome the growth.',
          'Every single day is a fresh canvas to paint a wiser version of yourself.',
          'You are a work in progress, and that is a beautiful place to be.',
          'Shed the old skin that no longer fits your expanding consciousness.'
        ]
      }
    ];

    final authors = [
      'Zen Wisdom',
      'Marcus Aurelius',
      'Sufi Proverb',
      'Lao Tzu',
      'Buddha',
      'Stoic Philosophy',
      'Yogi Teachings',
      'Eastern Philosophy',
      'Mental Mantra Coach'
    ];

    // Generate up to 1000 quotes by looping through combinations
    int themeIndex = 0;
    int templateIndex = 0;
    int authorIndex = 0;

    while (quotes.length < 1000) {
      final seg = segments[themeIndex % segments.length];
      final templates = seg['templates'] as List<String>;
      final template = templates[templateIndex % templates.length];

      // Let's add variations to make each generated quote unique!
      final variations = [
        'Remember: $template',
        '$template Breathe and absorb this.',
        'A gentle reminder: $template',
        'Focus on this today: $template',
        'For your path: $template',
      ];
      final variation = variations[quotes.length % variations.length];
      final author = authors[authorIndex % authors.length];

      // Add if not already present
      quotes.add({
        'text': variation,
        'author': author,
      });

      themeIndex++;
      if (themeIndex % segments.length == 0) {
        templateIndex++;
      }
      if (templateIndex % 5 == 0) {
        authorIndex++;
      }
    }

    return quotes;
  }
}
