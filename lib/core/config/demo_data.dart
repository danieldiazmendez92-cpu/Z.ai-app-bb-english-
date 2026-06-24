// =============================================================================
// demo_data.dart - Datos de prueba para Demo Mode
// -----------------------------------------------------------------------------
// 5 cuentos completos con secciones, vocabulario, preguntas y timestamps.
// No dependen de Firebase. Se cargan en memoria al arrancar la app.
// =============================================================================

import '../features/library/domain/entities/category.dart';
import '../features/progress/domain/entities/achievement.dart';
import '../features/progress/domain/entities/reading_stats.dart';
import '../features/story/domain/entities/audio_timestamp.dart';
import '../features/story/domain/entities/comprehension_question.dart';
import '../features/story/domain/entities/story.dart';
import '../features/story/domain/entities/story_section.dart';
import '../features/story/domain/entities/vocabulary_word.dart';

class DemoData {
  DemoData._();

  // ============================================================
  // Categorías
  // ============================================================
  static const List<Category> categories = [
    Category(
      categoryId: 'animals',
      name: 'Animals',
      nameEs: 'Animales',
      iconAsset: '🐾',
      order: 1,
    ),
    Category(
      categoryId: 'adventure',
      name: 'Adventure',
      nameEs: 'Aventuras',
      iconAsset: '🚀',
      order: 2,
    ),
    Category(
      categoryId: 'bedtime',
      name: 'Bedtime',
      nameEs: 'Hora de dormir',
      iconAsset: '🌙',
      order: 3,
    ),
    Category(
      categoryId: 'fairy',
      name: 'Fairy Tales',
      nameEs: 'Cuentos de hadas',
      iconAsset: '🧚',
      order: 4,
    ),
    Category(
      categoryId: 'classic',
      name: 'Classics',
      nameEs: 'Clásicos',
      iconAsset: '📖',
      order: 5,
    ),
  ];

  // ============================================================
  // Cuentos (5 cuentos completos)
  // ============================================================
  static List<Story> get stories => [
        Story(
          storyId: 'little-red-riding-hood',
          title: 'Little Red Riding Hood',
          categoryId: 'fairy',
          minAge: 4,
          maxAge: 7,
          durationMinutes: 5,
          audioUrlEn: 'demo://little-red-riding-hood',
          timestampsJsonUrl: 'demo://little-red-riding-hood/timestamps',
          coverImageUrl: '👧',
          sourceAttribution: 'Brothers Grimm, public domain',
          sourceUrl: 'https://www.gutenberg.org',
          published: true,
          tags: ['fairy', 'animals', 'classic', 'adventure'],
          createdAt: DateTime(2026, 6, 1),
          viewCount: 42,
        ),
        Story(
          storyId: 'three-little-pigs',
          title: 'The Three Little Pigs',
          categoryId: 'animals',
          minAge: 3,
          maxAge: 7,
          durationMinutes: 4,
          audioUrlEn: 'demo://three-little-pigs',
          timestampsJsonUrl: 'demo://three-little-pigs/timestamps',
          coverImageUrl: '🐷',
          sourceAttribution: 'Traditional folktale, public domain',
          sourceUrl: 'https://www.gutenberg.org',
          published: true,
          tags: ['animals', 'classic', 'adventure'],
          createdAt: DateTime(2026, 6, 5),
          viewCount: 78,
        ),
        Story(
          storyId: 'goldilocks',
          title: 'Goldilocks and the Three Bears',
          categoryId: 'fairy',
          minAge: 3,
          maxAge: 6,
          durationMinutes: 4,
          audioUrlEn: 'demo://goldilocks',
          timestampsJsonUrl: 'demo://goldilocks/timestamps',
          coverImageUrl: '🐻',
          sourceAttribution: 'Robert Southey, public domain',
          sourceUrl: 'https://www.gutenberg.org',
          published: true,
          tags: ['fairy', 'animals', 'bedtime'],
          createdAt: DateTime(2026, 6, 10),
          viewCount: 35,
        ),
        Story(
          storyId: 'ugly-duckling',
          title: 'The Ugly Duckling',
          categoryId: 'classic',
          minAge: 5,
          maxAge: 7,
          durationMinutes: 6,
          audioUrlEn: 'demo://ugly-duckling',
          timestampsJsonUrl: 'demo://ugly-duckling/timestamps',
          coverImageUrl: '🦆',
          sourceAttribution: 'Hans Christian Andersen, public domain',
          sourceUrl: 'https://www.gutenberg.org',
          published: true,
          tags: ['animals', 'classic', 'bedtime'],
          createdAt: DateTime(2026, 6, 12),
          viewCount: 29,
        ),
        Story(
          storyId: 'tortoise-hare',
          title: 'The Tortoise and the Hare',
          categoryId: 'classic',
          minAge: 2,
          maxAge: 6,
          durationMinutes: 3,
          audioUrlEn: 'demo://tortoise-hare',
          timestampsJsonUrl: 'demo://tortoise-hare/timestamps',
          coverImageUrl: '🐢',
          sourceAttribution: 'Aesop, public domain',
          sourceUrl: 'https://www.gutenberg.org',
          published: true,
          tags: ['animals', 'classic', 'learning'],
          createdAt: DateTime(2026, 6, 15),
          viewCount: 51,
        ),
      ];

  // ============================================================
  // Secciones por cuento (3 secciones cada uno)
  // ============================================================
  static Map<String, List<StorySection>> get storySections => {
        'little-red-riding-hood': [
          StorySection(
            sectionId: 'lrh-1',
            storyId: 'little-red-riding-hood',
            order: 1,
            textEn:
                'Once upon a time, there was a little girl called Little Red Riding Hood. She lived with her mother in a small house near the forest. One day, her mother gave her a basket of food. "Take this to your grandmother," her mother said. "She is sick in bed."',
            textEs:
                'Había una vez una niña llamada Caperucita Roja. Vivía con su madre en una pequeña casa cerca del bosque. Un día, su madre le dio una canasta con comida. "Lleva esto a tu abuela", dijo su madre. "Ella está enferma en cama."',
            illustrationUrl: '👧',
          ),
          StorySection(
            sectionId: 'lrh-2',
            storyId: 'little-red-riding-hood',
            order: 2,
            textEn:
                'In the forest, Little Red Riding Hood met a big wolf. "Where are you going, little girl?" asked the wolf. "I am going to my grandmother house," she said. The wolf ran ahead to grandmother house. He wanted to eat them both!',
            textEs:
                'En el bosque, Caperucita Roja se encontró con un gran lobo. "¿A dónde vas, niña?", preguntó el lobo. "Voy a la casa de mi abuela", dijo ella. El lobo corrió adelante hasta la casa de la abuela. ¡Quería comerse a las dos!',
            illustrationUrl: '🐺',
          ),
          StorySection(
            sectionId: 'lrh-3',
            storyId: 'little-red-riding-hood',
            order: 3,
            textEn:
                'The wolf dressed as grandmother. When Little Red Riding Hood arrived, she said, "Grandmother, what big eyes you have!" A hunter heard her scream and saved the day. The wolf ran away, and Little Red Riding Hood learned her lesson.',
            textEs:
                'El lobo se disfrazó de abuela. Cuando Caperucita Roja llegó, dijo: "¡Abuela, qué ojos tan grandes tienes!" Un cazador escuchó su grito y salvó el día. El lobo se fue corriendo, y Caperucita Roja aprendió la lección.',
            illustrationUrl: '👶',
          ),
        ],
        'three-little-pigs': [
          StorySection(
            sectionId: 'tlp-1',
            storyId: 'three-little-pigs',
            order: 1,
            textEn:
                'Once there were three little pigs. They left their mother to build their own houses. The first pig built a house of straw. The second pig built a house of wood. The third pig built a house of bricks.',
            textEs:
                'Había una vez tres cerditos. Dejaron a su madre para construir sus propias casas. El primer cerdito construyó una casa de paja. El segundo cerdito construyó una casa de madera. El tercer cerdito construyó una casa de ladrillos.',
            illustrationUrl: '🏠',
          ),
          StorySection(
            sectionId: 'tlp-2',
            storyId: 'three-little-pigs',
            order: 2,
            textEn:
                'A big bad wolf came. He huffed and puffed and blew the straw house down! The first pig ran to his brother wood house. The wolf huffed and puffed and blew the wood house down too! Both pigs ran to the brick house.',
            textEs:
                'Un gran lobo malo llegó. Sopló y sopló y tiró la casa de paja. El primer cerdito corrió a la casa de madera de su hermano. El lobo sopló y sopló y también tiró la casa de madera. Ambos cerditos corrieron a la casa de ladrillos.',
            illustrationUrl: '🐺',
          ),
          StorySection(
            sectionId: 'tlp-3',
            storyId: 'three-little-pigs',
            order: 3,
            textEn:
                'The wolf huffed and puffed but could not blow the brick house down. The three pigs were safe inside. The wolf tried to come down the chimney, but the pigs made a fire. The wolf ran away and never came back!',
            textEs:
                'El lobo sopló y sopló pero no pudo tirar la casa de ladrillos. Los tres cerditos estaban seguros adentro. El lobo intentó bajar por la chimenea, pero los cerditos hicieron fuego. ¡El lobo se fue corriendo y nunca volvió!',
            illustrationUrl: '🐷',
          ),
        ],
        'goldilocks': [
          StorySection(
            sectionId: 'g-1',
            storyId: 'goldilocks',
            order: 1,
            textEn:
                'Once there were three bears: Papa Bear, Mama Bear, and Baby Bear. They lived in a house in the forest. One morning, they made porridge for breakfast. The porridge was too hot, so they went for a walk.',
            textEs:
                'Había una vez tres osos: Papá Oso, Mamá Osa y Bebé Oso. Vivían en una casa en el bosque. Una mañana, hicieron gachas para desayunar. Las gachas estaban muy calientes, así que fueron a caminar.',
            illustrationUrl: '🐻',
          ),
          StorySection(
            sectionId: 'g-2',
            storyId: 'goldilocks',
            order: 2,
            textEn:
                'A little girl named Goldilocks came to the house. She went inside. She tasted the porridge. Papa porridge was too hot. Mama porridge was too cold. Baby porridge was just right, and she ate it all!',
            textEs:
                'Una niña llamada Ricitos de Oro llegó a la casa. Entró. Probó las gachas. Las de Papá estaban muy calientes. Las de Mamá estaban muy frías. ¡Las de Bebé estaban perfectas, y se las comió todas!',
            illustrationUrl: '👧',
          ),
          StorySection(
            sectionId: 'g-3',
            storyId: 'goldilocks',
            order: 3,
            textEn:
                'Goldilocks sat in the bears chairs and broke the baby chair. Then she slept in the baby bed. When the bears came home, they found her! Goldilocks woke up, screamed, and ran away. She never went back to the forest.',
            textEs:
                'Ricitos de Oro se sentó en las sillas de los osos y rompió la silla del bebé. Luego durmió en la cama del bebé. Cuando los osos volvieron a casa, ¡la encontraron! Ricitos de Oro se despertó, gritó y se fue corriendo. Nunca más volvió al bosque.',
            illustrationUrl: '🏃',
          ),
        ],
        'ugly-duckling': [
          StorySection(
            sectionId: 'ud-1',
            storyId: 'ugly-duckling',
            order: 1,
            textEn:
                'One summer, a mother duck sat on her eggs. One day, they hatched! Six pretty ducklings came out. But one egg was bigger. When it hatched, a big gray bird came out. "How ugly!" said the other ducks.',
            textEs:
                'Un verano, una mamá pata se sentó sobre sus huevos. Un día, ¡eclosionaron! Seis patitos bonitos salieron. Pero un huevo era más grande. Cuando eclosionó, salió un pájaro grande y gris. "¡Qué feo!", dijeron los otros patos.',
            illustrationUrl: '🥚',
          ),
          StorySection(
            sectionId: 'ud-2',
            storyId: 'ugly-duckling',
            order: 2,
            textEn:
                'The ugly duckling was sad. Everyone laughed at him. He ran away from home. He lived alone all winter. It was very cold and very sad. He cried many tears in the dark nights.',
            textEs:
                'El patito feo estaba triste. Todos se reían de él. Se fue de casa. Vivió solo todo el invierno. Hacía mucho frío y estaba muy triste. Lloró muchas lágrimas en las noches oscuras.',
            illustrationUrl: '😢',
          ),
          StorySection(
            sectionId: 'ud-3',
            storyId: 'ugly-duckling',
            order: 3,
            textEn:
                'Spring came. The ugly duckling saw beautiful swans in the lake. He looked at himself in the water. He was a swan too! He was not ugly at all. The other swans welcomed him. He was finally happy.',
            textEs:
                'Llegó la primavera. El patito feo vio hermosos cisnes en el lago. Se miró en el agua. ¡Él también era un cisne! No era feo para nada. Los otros cisnes lo recibieron. Finalmente era feliz.',
            illustrationUrl: '🦢',
          ),
        ],
        'tortoise-hare': [
          StorySection(
            sectionId: 'th-1',
            storyId: 'tortoise-hare',
            order: 1,
            textEn:
                'A hare was very fast. He laughed at the tortoise. "You are so slow!" said the hare. The tortoise said, "Let us have a race!" The hare laughed and laughed. "OK!" he said. The race began.',
            textEs:
                'Una liebre era muy rápida. Se rió de la tortuga. "¡Eres tan lenta!", dijo la liebre. La tortuga dijo: "¡Hagamos una carrera!" La liebre rió y rió. "¡OK!", dijo. La carrera comenzó.',
            illustrationUrl: '🐇',
          ),
          StorySection(
            sectionId: 'th-2',
            storyId: 'tortoise-hare',
            order: 2,
            textEn:
                'The hare ran very fast. Soon he was far ahead. "I will take a little nap," he thought. The tortoise walked slowly, step by step. She did not stop. She walked and walked.',
            textEs:
                'La liebre corrió muy rápido. Pronto estaba muy adelante. "Voy a tomar una siestita", pensó. La tortuga caminó lentamente, paso a paso. Ella no se detuvo. Caminó y caminó.',
            illustrationUrl: '😴',
          ),
          StorySection(
            sectionId: 'th-3',
            storyId: 'tortoise-hare',
            order: 3,
            textEn:
                'The tortoise reached the finish line. The hare woke up and ran fast, but it was too late! The tortoise won! "Slow and steady wins the race," said the tortoise. The hare learned his lesson.',
            textEs:
                'La tortuga llegó a la meta. La liebre se despertó y corrió rápido, ¡pero era demasiado tarde! ¡La tortuga ganó! "Lento pero constante gana la carrera", dijo la tortuga. La liebre aprendió su lección.',
            illustrationUrl: '🐢',
          ),
        ],
      };

  // ============================================================
  // Vocabulario por cuento
  // ============================================================
  static Map<String, List<VocabularyWord>> get storyVocabulary => {
        'little-red-riding-hood': [
          VocabularyWord(
            wordId: 'lrh-v1',
            storyId: 'little-red-riding-hood',
            wordEn: 'forest',
            wordEs: 'bosque',
            phonetic: '/ˈfɒrɪst/',
            exampleSentence: 'She walked into the forest.',
            exampleTranslation: 'Ella caminó hacia el bosque.',
            isHighlighted: true,
          ),
          VocabularyWord(
            wordId: 'lrh-v2',
            storyId: 'little-red-riding-hood',
            wordEn: 'wolf',
            wordEs: 'lobo',
            phonetic: '/wʊlf/',
            exampleSentence: 'The wolf was hungry.',
            exampleTranslation: 'El lobo estaba hambriento.',
            isHighlighted: true,
          ),
          VocabularyWord(
            wordId: 'lrh-v3',
            storyId: 'little-red-riding-hood',
            wordEn: 'grandmother',
            wordEs: 'abuela',
            phonetic: '/ˈɡrænmʌðər/',
            exampleSentence: 'Her grandmother was sick.',
            exampleTranslation: 'Su abuela estaba enferma.',
            isHighlighted: true,
          ),
          VocabularyWord(
            wordId: 'lrh-v4',
            storyId: 'little-red-riding-hood',
            wordEn: 'basket',
            wordEs: 'canasta',
            phonetic: '/ˈbɑːskɪt/',
            exampleSentence: 'She carried a basket of food.',
            exampleTranslation: 'Llevaba una canasta de comida.',
            isHighlighted: true,
          ),
        ],
        'three-little-pigs': [
          VocabularyWord(
            wordId: 'tlp-v1',
            storyId: 'three-little-pigs',
            wordEn: 'straw',
            wordEs: 'paja',
            phonetic: '/strɔː/',
            exampleSentence: 'The house was made of straw.',
            exampleTranslation: 'La casa era de paja.',
            isHighlighted: true,
          ),
          VocabularyWord(
            wordId: 'tlp-v2',
            storyId: 'three-little-pigs',
            wordEn: 'brick',
            wordEs: 'ladrillo',
            phonetic: '/brɪk/',
            exampleSentence: 'The brick house was strong.',
            exampleTranslation: 'La casa de ladrillos era fuerte.',
            isHighlighted: true,
          ),
          VocabularyWord(
            wordId: 'tlp-v3',
            storyId: 'three-little-pigs',
            wordEn: 'wolf',
            wordEs: 'lobo',
            phonetic: '/wʊlf/',
            exampleSentence: 'The wolf huffed and puffed.',
            exampleTranslation: 'El lobo sopló y sopló.',
            isHighlighted: true,
          ),
        ],
        'goldilocks': [
          VocabularyWord(
            wordId: 'g-v1',
            storyId: 'goldilocks',
            wordEn: 'porridge',
            wordEs: 'gachas',
            phonetic: '/ˈpɒrɪdʒ/',
            exampleSentence: 'She ate the porridge.',
            exampleTranslation: 'Ella comió las gachas.',
            isHighlighted: true,
          ),
          VocabularyWord(
            wordId: 'g-v2',
            storyId: 'goldilocks',
            wordEn: 'bears',
            wordEs: 'osos',
            phonetic: '/beərz/',
            exampleSentence: 'The three bears came home.',
            exampleTranslation: 'Los tres osos volvieron a casa.',
            isHighlighted: true,
          ),
        ],
        'ugly-duckling': [
          VocabularyWord(
            wordId: 'ud-v1',
            storyId: 'ugly-duckling',
            wordEn: 'duckling',
            wordEs: 'patito',
            phonetic: '/ˈdʌklɪŋ/',
            exampleSentence: 'The duckling was sad.',
            exampleTranslation: 'El patito estaba triste.',
            isHighlighted: true,
          ),
          VocabularyWord(
            wordId: 'ud-v2',
            storyId: 'ugly-duckling',
            wordEn: 'swan',
            wordEs: 'cisne',
            phonetic: '/swɒn/',
            exampleSentence: 'He became a beautiful swan.',
            exampleTranslation: 'Se convirtió en un hermoso cisne.',
            isHighlighted: true,
          ),
        ],
        'tortoise-hare': [
          VocabularyWord(
            wordId: 'th-v1',
            storyId: 'tortoise-hare',
            wordEn: 'tortoise',
            wordEs: 'tortuga',
            phonetic: '/ˈtɔːrtəs/',
            exampleSentence: 'The tortoise walked slowly.',
            exampleTranslation: 'La tortuga caminaba lentamente.',
            isHighlighted: true,
          ),
          VocabularyWord(
            wordId: 'th-v2',
            storyId: 'tortoise-hare',
            wordEn: 'hare',
            wordEs: 'liebre',
            phonetic: '/heər/',
            exampleSentence: 'The hare ran very fast.',
            exampleTranslation: 'La liebre corría muy rápido.',
            isHighlighted: true,
          ),
          VocabularyWord(
            wordId: 'th-v3',
            storyId: 'tortoise-hare',
            wordEn: 'race',
            wordEs: 'carrera',
            phonetic: '/reɪs/',
            exampleSentence: 'They had a race.',
            exampleTranslation: 'Tuvieron una carrera.',
            isHighlighted: true,
          ),
        ],
      };

  // ============================================================
  // Preguntas de comprensión
  // ============================================================
  static Map<String, List<ComprehensionQuestion>> get storyQuestions => {
        'little-red-riding-hood': [
          ComprehensionQuestion(
            questionId: 'lrh-q1',
            storyId: 'little-red-riding-hood',
            questionText: 'Who saved Little Red Riding Hood from the wolf?',
            options: [
              'Her mother',
              'A hunter',
              'The grandmother',
              'A friend',
            ],
            correctIndex: 1,
            explanation:
                'A hunter heard her scream and came to save her from the wolf.',
          ),
        ],
        'three-little-pigs': [
          ComprehensionQuestion(
            questionId: 'tlp-q1',
            storyId: 'three-little-pigs',
            questionText: 'Why couldnt the wolf blow down the brick house?',
            options: [
              'The wolf was tired',
              'Bricks are too heavy',
              'The house was too small',
              'The pigs helped',
            ],
            correctIndex: 1,
            explanation:
                'Bricks are heavy and strong. The wolf could not blow them down.',
          ),
        ],
        'goldilocks': [
          ComprehensionQuestion(
            questionId: 'g-q1',
            storyId: 'goldilocks',
            questionText: 'Whose porridge did Goldilocks eat?',
            options: [
              'Papa Bear',
              'Mama Bear',
              'Baby Bear',
              'Her own',
            ],
            correctIndex: 2,
            explanation:
                'Baby Bear porridge was just right, so she ate it all.',
          ),
        ],
        'ugly-duckling': [
          ComprehensionQuestion(
            questionId: 'ud-q1',
            storyId: 'ugly-duckling',
            questionText: 'What did the ugly duckling become?',
            options: [
              'A big duck',
              'A beautiful swan',
              'A goose',
              'A chicken',
            ],
            correctIndex: 1,
            explanation:
                'He was never ugly - he was a swan all along! In spring he saw his reflection.',
          ),
        ],
        'tortoise-hare': [
          ComprehensionQuestion(
            questionId: 'th-q1',
            storyId: 'tortoise-hare',
            questionText: 'Why did the tortoise win the race?',
            options: [
              'She ran faster',
              'The hare got lost',
              'She never stopped, the hare napped',
              'The hare helped her',
            ],
            correctIndex: 2,
            explanation:
                'The hare took a nap because he was ahead. The tortoise kept walking and won!',
          ),
        ],
      };

  // ============================================================
  // Timestamps generados automáticamente por palabra
  // ============================================================
  /// Genera timestamps simples: cada palabra dura ~400ms.
  /// En producción vienen de Google TTS.
  static Map<String, AudioTimestamps> get storyTimestamps {
    final map = <String, AudioTimestamps>{};
    for (final entry in storySections.entries) {
      final storyId = entry.key;
      final sections = entry.value;
      final allText = sections.map((s) => s.textEn).join(' ');
      final words = allText.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();

      final timestamps = <AudioTimestamp>[];
      var currentMs = 0;
      for (final word in words) {
        // ~400ms por palabra (en producción varía según TTS)
        final wordDuration = 400;
        timestamps.add(AudioTimestamp(
          word: word,
          startMs: currentMs,
          endMs: currentMs + wordDuration,
        ));
        currentMs += wordDuration;
      }

      map[storyId] = AudioTimestamps(timestamps: timestamps);
    }
    return map;
  }

  // ============================================================
  // Logros (10)
  // ============================================================
  static const List<Achievement> achievements = [
    Achievement(
      achievementId: 'first_story',
      name: 'First Steps',
      description: 'Leíste tu primer cuento',
      iconUrl: '👶',
      emoji: '👶',
      criteriaType: 'stories_completed',
      criteriaThreshold: 1,
      xpReward: 10,
    ),
    Achievement(
      achievementId: 'stories_5',
      name: 'Bookworm',
      description: 'Completaste 5 cuentos',
      iconUrl: '📖',
      emoji: '📖',
      criteriaType: 'stories_completed',
      criteriaThreshold: 5,
      xpReward: 25,
    ),
    Achievement(
      achievementId: 'stories_10',
      name: 'Story Explorer',
      description: 'Completaste 10 cuentos',
      iconUrl: '🧭',
      emoji: '🧭',
      criteriaType: 'stories_completed',
      criteriaThreshold: 10,
      xpReward: 50,
    ),
    Achievement(
      achievementId: 'streak_3_days',
      name: 'On Fire',
      description: 'Leíste 3 días seguidos',
      iconUrl: '🔥',
      emoji: '🔥',
      criteriaType: 'streak_days',
      criteriaThreshold: 3,
      xpReward: 20,
    ),
    Achievement(
      achievementId: 'streak_7_days',
      name: 'Week Warrior',
      description: 'Leíste 7 días seguidos',
      iconUrl: '⚔️',
      emoji: '⚔️',
      criteriaType: 'streak_days',
      criteriaThreshold: 7,
      xpReward: 50,
    ),
    Achievement(
      achievementId: 'words_50',
      name: 'Word Collector',
      description: 'Aprendiste 50 palabras nuevas',
      iconUrl: '📚',
      emoji: '📚',
      criteriaType: 'words_learned',
      criteriaThreshold: 50,
      xpReward: 40,
    ),
    Achievement(
      achievementId: 'categories_3',
      name: 'Explorer',
      description: 'Exploraste 3 categorías diferentes',
      iconUrl: '🗺️',
      emoji: '🗺️',
      criteriaType: 'categories_explored',
      criteriaThreshold: 3,
      xpReward: 30,
    ),
    Achievement(
      achievementId: 'time_60_min',
      name: 'Time Traveler',
      description: 'Leíste por 60 minutos en total',
      iconUrl: '⏰',
      emoji: '⏰',
      criteriaType: 'time_spent_minutes',
      criteriaThreshold: 60,
      xpReward: 35,
    ),
  ];

  // ============================================================
  // Stats iniciales (demo: el niño ya leyó 2 cuentos)
  // ============================================================
  static ReadingStats get initialStats => const ReadingStats(
        storiesCompleted: 2,
        storiesStarted: 3,
        totalMinutes: 8,
        wordsLearned: 16,
        currentStreak: 1,
        longestStreak: 3,
        categoriesExplored: 2,
        achievementsUnlocked: 1,
        lastReadDate: null,
      );
}
