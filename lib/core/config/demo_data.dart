// =============================================================================
// demo_data.dart - Datos de prueba para Demo Mode (revisión pedagógica v2)
// -----------------------------------------------------------------------------
// 10 cuentos: 5 clásicos corregidos + 3 nursery rhymes + 2 diversidad cultural
// Vocabulario expandido: de 14 a 35+ palabras destacadas
// Correcciones: gramática (posesivo sajón), traducciones, minAge apropiado
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
  // Categorías (agregamos nursery y world)
  // ============================================================
  static const List<Category> categories = [
    Category(categoryId: 'animals', name: 'Animals', nameEs: 'Animales', iconAsset: '🐾', order: 1),
    Category(categoryId: 'adventure', name: 'Adventure', nameEs: 'Aventuras', iconAsset: '🚀', order: 2),
    Category(categoryId: 'bedtime', name: 'Bedtime', nameEs: 'Hora de dormir', iconAsset: '🌙', order: 3),
    Category(categoryId: 'fairy', name: 'Fairy Tales', nameEs: 'Cuentos de hadas', iconAsset: '🧚', order: 4),
    Category(categoryId: 'classic', name: 'Classics', nameEs: 'Clásicos', iconAsset: '📖', order: 5),
    Category(categoryId: 'nursery', name: 'Nursery Rhymes', nameEs: 'Canciones infantiles', iconAsset: '🎵', order: 6),
    Category(categoryId: 'world', name: 'Around the World', nameEs: 'Cuentos del mundo', iconAsset: '🌍', order: 7),
  ];

  // ============================================================
  // CUENTOS (10 total)
  // ============================================================
  static List<Story> get stories => [
    Story(storyId: 'little-red-riding-hood', title: 'Little Red Riding Hood', categoryId: 'fairy', minAge: 4, maxAge: 7, durationMinutes: 5, audioUrlEn: 'demo://little-red-riding-hood', timestampsJsonUrl: 'demo://little-red-riding-hood/timestamps', coverImageUrl: '👧', sourceAttribution: 'Brothers Grimm, public domain', sourceUrl: 'https://www.gutenberg.org', published: true, tags: ['fairy', 'animals', 'classic', 'adventure'], createdAt: DateTime(2026, 6, 1), viewCount: 42),
    Story(storyId: 'three-little-pigs', title: 'The Three Little Pigs', categoryId: 'animals', minAge: 3, maxAge: 7, durationMinutes: 4, audioUrlEn: 'demo://three-little-pigs', timestampsJsonUrl: 'demo://three-little-pigs/timestamps', coverImageUrl: '🐷', sourceAttribution: 'Traditional folktale, public domain', sourceUrl: 'https://www.gutenberg.org', published: true, tags: ['animals', 'classic', 'adventure'], createdAt: DateTime(2026, 6, 5), viewCount: 78),
    Story(storyId: 'goldilocks', title: 'Goldilocks and the Three Bears', categoryId: 'fairy', minAge: 3, maxAge: 6, durationMinutes: 4, audioUrlEn: 'demo://goldilocks', timestampsJsonUrl: 'demo://goldilocks/timestamps', coverImageUrl: '🐻', sourceAttribution: 'Robert Southey, public domain', sourceUrl: 'https://www.gutenberg.org', published: true, tags: ['fairy', 'animals', 'bedtime'], createdAt: DateTime(2026, 6, 10), viewCount: 35),
    Story(storyId: 'ugly-duckling', title: 'The Ugly Duckling', categoryId: 'classic', minAge: 5, maxAge: 7, durationMinutes: 6, audioUrlEn: 'demo://ugly-duckling', timestampsJsonUrl: 'demo://ugly-duckling/timestamps', coverImageUrl: '🦆', sourceAttribution: 'Hans Christian Andersen, public domain', sourceUrl: 'https://www.gutenberg.org', published: true, tags: ['animals', 'classic', 'bedtime'], createdAt: DateTime(2026, 6, 12), viewCount: 29),
    // CORRECCIÓN: minAge cambiado de 2 a 4 (toddlers no deberían usar apps de cuentos estructurados)
    Story(storyId: 'tortoise-hare', title: 'The Tortoise and the Hare', categoryId: 'classic', minAge: 4, maxAge: 7, durationMinutes: 3, audioUrlEn: 'demo://tortoise-hare', timestampsJsonUrl: 'demo://tortoise-hare/timestamps', coverImageUrl: '🐢', sourceAttribution: 'Aesop, public domain', sourceUrl: 'https://www.gutenberg.org', published: true, tags: ['animals', 'classic', 'learning'], createdAt: DateTime(2026, 6, 15), viewCount: 51),
    // ===== 3 Nursery Rhymes (para 2-5 años) =====
    Story(storyId: 'twinkle-twinkle', title: 'Twinkle, Twinkle, Little Star', categoryId: 'nursery', minAge: 2, maxAge: 5, durationMinutes: 1, audioUrlEn: 'demo://twinkle-twinkle', timestampsJsonUrl: 'demo://twinkle-twinkle/timestamps', coverImageUrl: '⭐', sourceAttribution: 'Jane Taylor, 1806, public domain', sourceUrl: 'https://www.gutenberg.org', published: true, tags: ['nursery', 'bedtime'], createdAt: DateTime(2026, 6, 16), viewCount: 95),
    Story(storyId: 'humpty-dumpty', title: 'Humpty Dumpty', categoryId: 'nursery', minAge: 2, maxAge: 5, durationMinutes: 1, audioUrlEn: 'demo://humpty-dumpty', timestampsJsonUrl: 'demo://humpty-dumpty/timestamps', coverImageUrl: '🥚', sourceAttribution: 'Traditional English nursery rhyme, public domain', sourceUrl: 'https://www.gutenberg.org', published: true, tags: ['nursery'], createdAt: DateTime(2026, 6, 17), viewCount: 67),
    Story(storyId: 'itsy-bitsy-spider', title: 'Itsy Bitsy Spider', categoryId: 'nursery', minAge: 2, maxAge: 5, durationMinutes: 1, audioUrlEn: 'demo://itsy-bitsy-spider', timestampsJsonUrl: 'demo://itsy-bitsy-spider/timestamps', coverImageUrl: '🕷️', sourceAttribution: 'Traditional American nursery rhyme, public domain', sourceUrl: 'https://www.gutenberg.org', published: true, tags: ['nursery', 'animals'], createdAt: DateTime(2026, 6, 18), viewCount: 88),
    // ===== 2 Cuentos con diversidad cultural =====
    Story(storyId: 'anansi-spider', title: 'Anansi and the Pot of Beans', categoryId: 'world', minAge: 4, maxAge: 7, durationMinutes: 4, audioUrlEn: 'demo://anansi-spider', timestampsJsonUrl: 'demo://anansi-spider/timestamps', coverImageUrl: '🕷️', sourceAttribution: 'Ashanti folktale from Ghana, public domain', sourceUrl: 'https://www.gutenberg.org', published: true, tags: ['world', 'animals', 'adventure'], createdAt: DateTime(2026, 6, 19), viewCount: 23),
    Story(storyId: 'three-wishes', title: 'The Three Wishes', categoryId: 'world', minAge: 4, maxAge: 7, durationMinutes: 4, audioUrlEn: 'demo://three-wishes', timestampsJsonUrl: 'demo://three-wishes/timestamps', coverImageUrl: '🌟', sourceAttribution: 'Latin American folktale, public domain', sourceUrl: 'https://www.gutenberg.org', published: true, tags: ['world', 'fairy', 'learning'], createdAt: DateTime(2026, 6, 20), viewCount: 31),
  ];

  // ============================================================
  // SECCIONES POR CUENTO (con gramática corregida)
  // ============================================================
  static Map<String, List<StorySection>> get storySections => {
    'little-red-riding-hood': [
      StorySection(sectionId: 'lrh-1', storyId: 'little-red-riding-hood', order: 1,
        textEn: "Once upon a time, there was a little girl called Little Red Riding Hood. She lived with her mother in a small house near the forest. One day, her mother gave her a basket of food. \"Take this to your grandmother's house,\" her mother said. \"She is sick in bed.\"",
        textEs: 'Había una vez una niña llamada Caperucita Roja. Vivía con su madre en una pequeña casa cerca del bosque. Un día, su madre le dio una canasta con comida. "Lleva esto a la casa de tu abuela", dijo su madre. "Ella está enferma en cama."',
        illustrationUrl: '👧'),
      StorySection(sectionId: 'lrh-2', storyId: 'little-red-riding-hood', order: 2,
        textEn: "In the forest, Little Red Riding Hood met a big wolf. \"Where are you going, little girl?\" asked the wolf. \"I am going to my grandmother's house,\" she said. The wolf ran ahead to grandmother's house. He wanted to eat them both!",
        textEs: 'En el bosque, Caperucita Roja se encontró con un gran lobo. "¿A dónde vas, niña?", preguntó el lobo. "Voy a la casa de mi abuela", dijo ella. El lobo corrió adelante hasta la casa de la abuela. ¡Quería comerse a las dos!',
        illustrationUrl: '🐺'),
      StorySection(sectionId: 'lrh-3', storyId: 'little-red-riding-hood', order: 3,
        textEn: "The wolf dressed as grandmother. When Little Red Riding Hood arrived, she said, \"Grandmother, what big eyes you have!\" A hunter heard her scream and saved the day. The wolf ran away, and Little Red Riding Hood learned her lesson.",
        textEs: 'El lobo se disfrazó de abuela. Cuando Caperucita Roja llegó, dijo: "¡Abuela, qué ojos tan grandes tienes!" Un cazador escuchó su grito y salvó el día. El lobo se fue corriendo, y Caperucita Roja aprendió la lección.',
        illustrationUrl: '👶'),
    ],
    'three-little-pigs': [
      StorySection(sectionId: 'tlp-1', storyId: 'three-little-pigs', order: 1,
        textEn: 'Once there were three little pigs. They left their mother to build their own houses. The first pig built a house of straw. The second pig built a house of wood. The third pig built a house of bricks.',
        textEs: 'Había una vez tres cerditos. Dejaron a su madre para construir sus propias casas. El primer cerdito construyó una casa de paja. El segundo cerdito construyó una casa de madera. El tercer cerdito construyó una casa de ladrillos.',
        illustrationUrl: '🏠'),
      StorySection(sectionId: 'tlp-2', storyId: 'three-little-pigs', order: 2,
        textEn: "A big bad wolf came. He huffed and puffed and blew the straw house down! The first pig ran to his brother's wood house. The wolf huffed and puffed and blew the wood house down too! Both pigs ran to the brick house.",
        textEs: 'Un gran lobo malo llegó. Sopló y sopló y tiró la casa de paja. El primer cerdito corrió a la casa de madera de su hermano. El lobo sopló y sopló y también tiró la casa de madera. Ambos cerditos corrieron a la casa de ladrillos.',
        illustrationUrl: '🐺'),
      StorySection(sectionId: 'tlp-3', storyId: 'three-little-pigs', order: 3,
        textEn: 'The wolf huffed and puffed but could not blow the brick house down. The three pigs were safe inside. The wolf tried to come down the chimney, but the pigs made a fire. The wolf ran away and never came back!',
        textEs: 'El lobo sopló y sopló pero no pudo tirar la casa de ladrillos. Los tres cerditos estaban seguros adentro. El lobo intentó bajar por la chimenea, pero los cerditos hicieron fuego. ¡El lobo se fue corriendo y nunca volvió!',
        illustrationUrl: '🐷'),
    ],
    'goldilocks': [
      StorySection(sectionId: 'g-1', storyId: 'goldilocks', order: 1,
        textEn: 'Once there were three bears: Papa Bear, Mama Bear, and Baby Bear. They lived in a house in the forest. One morning, they made porridge for breakfast. The porridge was too hot, so they went for a walk.',
        textEs: 'Había una vez tres osos: Papá Oso, Mamá Osa y Bebé Oso. Vivían en una casa en el bosque. Una mañana, hicieron gachas para desayunar. Las gachas estaban muy calientes, así que fueron a caminar.',
        illustrationUrl: '🐻'),
      StorySection(sectionId: 'g-2', storyId: 'goldilocks', order: 2,
        textEn: "A little girl named Goldilocks came to the house. She went inside. She tasted the porridge. Papa's porridge was too hot. Mama's porridge was too cold. Baby's porridge was just right, and she ate it all!",
        textEs: 'Una niña llamada Ricitos de Oro llegó a la casa. Entró. Probó las gachas. Las de Papá estaban muy calientes. Las de Mamá estaban muy frías. ¡Las de Bebé estaban perfectas, y se las comió todas!',
        illustrationUrl: '👧'),
      StorySection(sectionId: 'g-3', storyId: 'goldilocks', order: 3,
        textEn: "Goldilocks sat in the bears' chairs and broke Baby's chair. Then she slept in the baby's bed. When the bears came home, they found her! Goldilocks woke up, screamed, and ran away. She never went back to the forest.",
        textEs: 'Ricitos de Oro se sentó en las sillas de los osos y rompió la silla del bebé. Luego durmió en la cama del bebé. Cuando los osos volvieron a casa, ¡la encontraron! Ricitos de Oro se despertó, gritó y se fue corriendo. Nunca más volvió al bosque.',
        illustrationUrl: '🏃'),
    ],
    'ugly-duckling': [
      StorySection(sectionId: 'ud-1', storyId: 'ugly-duckling', order: 1,
        textEn: 'One summer, a mother duck sat on her eggs. One day, they hatched! Six pretty ducklings came out. But one egg was bigger. When it hatched, a big gray bird came out. "How ugly!" said the other ducks.',
        textEs: 'Un verano, una mamá pata se sentó sobre sus huevos. Un día, ¡abrieron! Salieron seis patitos bonitos. Pero un huevo era más grande. Cuando abrió, salió un pájaro grande y gris. "¡Qué feo!", dijeron los otros patos.',
        illustrationUrl: '🥚'),
      StorySection(sectionId: 'ud-2', storyId: 'ugly-duckling', order: 2,
        textEn: 'The ugly duckling was sad. Everyone laughed at him. He ran away from home. He lived alone all winter. It was very cold and very sad. He cried many tears in the dark nights.',
        textEs: 'El patito feo estaba triste. Todos se reían de él. Se fue de casa. Vivió solo todo el invierno. Hacía mucho frío y estaba muy triste. Lloró muchas lágrimas en las noches oscuras.',
        illustrationUrl: '😢'),
      StorySection(sectionId: 'ud-3', storyId: 'ugly-duckling', order: 3,
        textEn: 'Spring came. The ugly duckling saw beautiful swans in the lake. He looked at himself in the water. He was a swan too! He was not ugly at all. The other swans welcomed him. He was finally happy.',
        textEs: 'Llegó la primavera. El patito feo vio hermosos cisnes en el lago. Se miró en el agua. ¡Él también era un cisne! No era feo para nada. Los otros cisnes lo recibieron. Finalmente era feliz.',
        illustrationUrl: '🦢'),
    ],
    'tortoise-hare': [
      StorySection(sectionId: 'th-1', storyId: 'tortoise-hare', order: 1,
        textEn: 'A hare was very fast. He laughed at the tortoise. "You are so slow!" said the hare. The tortoise said, "Let us have a race!" The hare laughed and laughed. "OK!" he said. The race began.',
        textEs: 'Una liebre era muy rápida. Se rió de la tortuga. "¡Eres tan lenta!", dijo la liebre. La tortuga dijo: "¡Hagamos una carrera!" La liebre se rió y se rió. "¡OK!", dijo. La carrera comenzó.',
        illustrationUrl: '🐇'),
      StorySection(sectionId: 'th-2', storyId: 'tortoise-hare', order: 2,
        textEn: 'The hare ran very fast. Soon he was far ahead. "I will take a little nap," he thought. The tortoise walked slowly, step by step. She did not stop. She walked and walked.',
        textEs: 'La liebre corrió muy rápido. Pronto estaba muy adelante. "Voy a tomar una siestita", pensó. La tortuga caminó lentamente, paso a paso. Ella no se detuvo. Caminó y caminó.',
        illustrationUrl: '😴'),
      StorySection(sectionId: 'th-3', storyId: 'tortoise-hare', order: 3,
        textEn: 'The tortoise reached the finish line. The hare woke up and ran fast, but it was too late! The tortoise won! "Slow and steady wins the race," said the tortoise. The hare learned his lesson.',
        textEs: 'La tortuga llegó a la meta. La liebre se despertó y corrió rápido, ¡pero era demasiado tarde! ¡La tortuga ganó! "Lento pero constante gana la carrera", dijo la tortuga. La liebre aprendió su lección.',
        illustrationUrl: '🐢'),
    ],
    'twinkle-twinkle': [
      StorySection(sectionId: 'tt-1', storyId: 'twinkle-twinkle', order: 1,
        textEn: "Twinkle, twinkle, little star,\nHow I wonder what you are!\nUp above the world so high,\nLike a diamond in the sky.\nTwinkle, twinkle, little star,\nHow I wonder what you are!",
        textEs: 'Brilla, brilla, estrellita,\n¡Cómo me pregunto qué serás!\nAllá arriba tan en lo alto,\nComo un diamante en el cielo.\nBrilla, brilla, estrellita,\n¡Cómo me pregunto qué serás!',
        illustrationUrl: '⭐'),
    ],
    'humpty-dumpty': [
      StorySection(sectionId: 'hd-1', storyId: 'humpty-dumpty', order: 1,
        textEn: "Humpty Dumpty sat on a wall,\nHumpty Dumpty had a great fall.\nAll the king's horses and all the king's men\nCouldn't put Humpty together again.",
        textEs: 'Humpty Dumpty se sentó en un muro,\nHumpty Dumpty tuvo una gran caída.\nTodos los caballos del rey y todos los hombres del rey\nNo pudieron armar a Humpty de nuevo.',
        illustrationUrl: '🥚'),
    ],
    'itsy-bitsy-spider': [
      StorySection(sectionId: 'ibs-1', storyId: 'itsy-bitsy-spider', order: 1,
        textEn: "The itsy bitsy spider climbed up the waterspout.\nDown came the rain, and washed the spider out.\nOut came the sun, and dried up all the rain,\nand the itsy bitsy spider climbed up the spout again.",
        textEs: 'La arañita chiquita subió por el desagüe.\nVino la lluvia, y lavó a la araña afuera.\nSalió el sol, y secó toda la lluvia,\ny la arañita chiquita subió por el desagüe de nuevo.',
        illustrationUrl: '🕷️'),
    ],
    'anansi-spider': [
      StorySection(sectionId: 'as-1', storyId: 'anansi-spider', order: 1,
        textEn: "Anansi the Spider was a trickster. He lived in a village in Africa. One day, Anansi found a pot of magic beans. \"These beans will make me strong!\" said Anansi. But he did not want to share.",
        textEs: 'Anansi la Araña era un tramposo. Vivía en un pueblo en África. Un día, Anansi encontró una olla de frijoles mágicos. "¡Estos frijoles me harán fuerte!", dijo Anansi. Pero no quería compartir.',
        illustrationUrl: '🕷️'),
      StorySection(sectionId: 'as-2', storyId: 'anansi-spider', order: 2,
        textEn: "Anansi tried to carry the pot up a tall tree. But the pot was heavy! He dropped it. The beans fell everywhere. Anansi was sad. \"Now nobody can have the magic beans,\" he said.",
        textEs: 'Anansi intentó llevar la olla arriba de un árbol alto. ¡Pero la olla era pesada! La dejó caer. Los frijoles cayeron por todas partes. Anansi estaba triste. "Ahora nadie puede tener los frijoles mágicos", dijo.',
        illustrationUrl: '🌳'),
      StorySection(sectionId: 'as-3', storyId: 'anansi-spider', order: 3,
        textEn: "But something wonderful happened! The beans grew into beautiful plants. The village had food for everyone. Anansi learned that sharing is better than keeping everything for yourself.",
        textEs: '¡Pero algo maravilloso pasó! Los frijoles crecieron en plantas hermosas. El pueblo tuvo comida para todos. Anansi aprendió que compartir es mejor que guardar todo para uno mismo.',
        illustrationUrl: '🌱'),
    ],
    'three-wishes': [
      StorySection(sectionId: 'tw-1', storyId: 'three-wishes', order: 1,
        textEn: "Once, a poor farmer helped a magical bird. \"Thank you,\" said the bird. \"I will give you three wishes!\" The farmer ran home to tell his wife. \"We can wish for anything!\" he said.",
        textEs: 'Una vez, un granjero pobre ayudó a un pájaro mágico. "Gracias", dijo el pájaro. "¡Te daré tres deseos!" El granjero corrió a casa para decírselo a su esposa. "¡Podemos pedir cualquier cosa!", dijo.',
        illustrationUrl: '🐦'),
      StorySection(sectionId: 'tw-2', storyId: 'three-wishes', order: 2,
        textEn: "His wife said, \"Let us wish for food!\" The farmer agreed. \"I wish for a big dinner!\" Suddenly, a feast appeared. They ate and ate. But they were still hungry for more.",
        textEs: 'Su esposa dijo: "¡Pidamos comida!" El granjero estuvo de acuerdo. "¡Deseo una gran cena!" De repente, apareció un banquete. Comieron y comieron. Pero todavía tenían más hambre.',
        illustrationUrl: '🍽️'),
      StorySection(sectionId: 'tw-3', storyId: 'three-wishes', order: 3,
        textEn: "For the second wish, they asked for gold. But the gold was heavy and they could not carry it. For the third wish, they asked for happiness. And that was the best wish of all. They lived happily ever after.",
        textEs: 'Para el segundo deseo, pidieron oro. Pero el oro era pesado y no podían llevarlo. Para el tercer deseo, pidieron felicidad. Y ese fue el mejor deseo de todos. Vivieron felices para siempre.',
        illustrationUrl: '🌟'),
    ],
  };

  // ============================================================
  // VOCABULARIO POR CUENTO (expandido: 14 → 35+ palabras)
  // ============================================================
  static Map<String, List<VocabularyWord>> get storyVocabulary => {
    'little-red-riding-hood': [
      VocabularyWord(wordId: 'lrh-v1', storyId: 'little-red-riding-hood', wordEn: 'forest', wordEs: 'bosque', phonetic: '/ˈfɒrɪst/', exampleSentence: 'She walked into the forest.', exampleTranslation: 'Ella caminó hacia el bosque.', isHighlighted: true),
      VocabularyWord(wordId: 'lrh-v2', storyId: 'little-red-riding-hood', wordEn: 'wolf', wordEs: 'lobo', phonetic: '/wʊlf/', exampleSentence: 'The wolf was hungry.', exampleTranslation: 'El lobo estaba hambriento.', isHighlighted: true),
      VocabularyWord(wordId: 'lrh-v3', storyId: 'little-red-riding-hood', wordEn: 'grandmother', wordEs: 'abuela', phonetic: '/ˈɡrænmʌðər/', exampleSentence: 'Her grandmother was sick.', exampleTranslation: 'Su abuela estaba enferma.', isHighlighted: true),
      VocabularyWord(wordId: 'lrh-v4', storyId: 'little-red-riding-hood', wordEn: 'basket', wordEs: 'canasta', phonetic: '/ˈbɑːskɪt/', exampleSentence: 'She carried a basket of food.', exampleTranslation: 'Llevaba una canasta de comida.', isHighlighted: true),
      VocabularyWord(wordId: 'lrh-v5', storyId: 'little-red-riding-hood', wordEn: 'house', wordEs: 'casa', phonetic: '/haʊs/', exampleSentence: "She went to her grandmother's house.", exampleTranslation: 'Ella fue a la casa de su abuela.', isHighlighted: true),
      VocabularyWord(wordId: 'lrh-v6', storyId: 'little-red-riding-hood', wordEn: 'mother', wordEs: 'madre', phonetic: '/ˈmʌðər/', exampleSentence: 'Her mother gave her a basket.', exampleTranslation: 'Su madre le dio una canasta.', isHighlighted: true),
      VocabularyWord(wordId: 'lrh-v7', storyId: 'little-red-riding-hood', wordEn: 'big', wordEs: 'grande', phonetic: '/bɪɡ/', exampleSentence: 'She met a big wolf.', exampleTranslation: 'Ella se encontró con un gran lobo.', isHighlighted: true),
    ],
    'three-little-pigs': [
      VocabularyWord(wordId: 'tlp-v1', storyId: 'three-little-pigs', wordEn: 'pig', wordEs: 'cerdo', phonetic: '/pɪɡ/', exampleSentence: 'The three pigs built houses.', exampleTranslation: 'Los tres cerditos construyeron casas.', isHighlighted: true),
      VocabularyWord(wordId: 'tlp-v2', storyId: 'three-little-pigs', wordEn: 'house', wordEs: 'casa', phonetic: '/haʊs/', exampleSentence: 'The pig built a house.', exampleTranslation: 'El cerdito construyó una casa.', isHighlighted: true),
      VocabularyWord(wordId: 'tlp-v3', storyId: 'three-little-pigs', wordEn: 'wolf', wordEs: 'lobo', phonetic: '/wʊlf/', exampleSentence: 'The wolf huffed and puffed.', exampleTranslation: 'El lobo sopló y sopló.', isHighlighted: true),
      VocabularyWord(wordId: 'tlp-v4', storyId: 'three-little-pigs', wordEn: 'straw', wordEs: 'paja', phonetic: '/strɔː/', exampleSentence: 'The house was made of straw.', exampleTranslation: 'La casa era de paja.', isHighlighted: true),
      VocabularyWord(wordId: 'tlp-v5', storyId: 'three-little-pigs', wordEn: 'brick', wordEs: 'ladrillo', phonetic: '/brɪk/', exampleSentence: 'The brick house was strong.', exampleTranslation: 'La casa de ladrillos era fuerte.', isHighlighted: true),
      VocabularyWord(wordId: 'tlp-v6', storyId: 'three-little-pigs', wordEn: 'brother', wordEs: 'hermano', phonetic: '/ˈbrʌðər/', exampleSentence: "He ran to his brother's house.", exampleTranslation: 'Corrió a la casa de su hermano.', isHighlighted: true),
      VocabularyWord(wordId: 'tlp-v7', storyId: 'three-little-pigs', wordEn: 'safe', wordEs: 'seguro', phonetic: '/seɪf/', exampleSentence: 'The pigs were safe inside.', exampleTranslation: 'Los cerditos estaban seguros adentro.', isHighlighted: true),
    ],
    'goldilocks': [
      VocabularyWord(wordId: 'g-v1', storyId: 'goldilocks', wordEn: 'bear', wordEs: 'oso', phonetic: '/beər/', exampleSentence: 'The three bears lived in the forest.', exampleTranslation: 'Los tres osos vivían en el bosque.', isHighlighted: true),
      VocabularyWord(wordId: 'g-v2', storyId: 'goldilocks', wordEn: 'porridge', wordEs: 'gachas', phonetic: '/ˈpɒrɪdʒ/', exampleSentence: 'She ate the porridge.', exampleTranslation: 'Ella comió las gachas.', isHighlighted: true),
      VocabularyWord(wordId: 'g-v3', storyId: 'goldilocks', wordEn: 'hot', wordEs: 'caliente', phonetic: '/hɒt/', exampleSentence: 'The porridge was too hot.', exampleTranslation: 'Las gachas estaban muy calientes.', isHighlighted: true),
      VocabularyWord(wordId: 'g-v4', storyId: 'goldilocks', wordEn: 'cold', wordEs: 'frío', phonetic: '/kəʊld/', exampleSentence: 'The porridge was too cold.', exampleTranslation: 'Las gachas estaban muy frías.', isHighlighted: true),
      VocabularyWord(wordId: 'g-v5', storyId: 'goldilocks', wordEn: 'chair', wordEs: 'silla', phonetic: '/tʃeər/', exampleSentence: "She broke the baby's chair.", exampleTranslation: 'Ella rompió la silla del bebé.', isHighlighted: true),
      VocabularyWord(wordId: 'g-v6', storyId: 'goldilocks', wordEn: 'bed', wordEs: 'cama', phonetic: '/bed/', exampleSentence: "She slept in the baby's bed.", exampleTranslation: 'Ella durmió en la cama del bebé.', isHighlighted: true),
    ],
    'ugly-duckling': [
      VocabularyWord(wordId: 'ud-v1', storyId: 'ugly-duckling', wordEn: 'duckling', wordEs: 'patito', phonetic: '/ˈdʌklɪŋ/', exampleSentence: 'The duckling was sad.', exampleTranslation: 'El patito estaba triste.', isHighlighted: true),
      VocabularyWord(wordId: 'ud-v2', storyId: 'ugly-duckling', wordEn: 'swan', wordEs: 'cisne', phonetic: '/swɒn/', exampleSentence: 'He became a beautiful swan.', exampleTranslation: 'Se convirtió en un hermoso cisne.', isHighlighted: true),
      VocabularyWord(wordId: 'ud-v3', storyId: 'ugly-duckling', wordEn: 'ugly', wordEs: 'feo', phonetic: '/ˈʌɡli/', exampleSentence: 'They said he was ugly.', exampleTranslation: 'Dijeron que era feo.', isHighlighted: true),
      VocabularyWord(wordId: 'ud-v4', storyId: 'ugly-duckling', wordEn: 'sad', wordEs: 'triste', phonetic: '/sæd/', exampleSentence: 'The duckling was very sad.', exampleTranslation: 'El patito estaba muy triste.', isHighlighted: true),
      VocabularyWord(wordId: 'ud-v5', storyId: 'ugly-duckling', wordEn: 'happy', wordEs: 'feliz', phonetic: '/ˈhæpi/', exampleSentence: 'He was finally happy.', exampleTranslation: 'Finalmente era feliz.', isHighlighted: true),
    ],
    'tortoise-hare': [
      VocabularyWord(wordId: 'th-v1', storyId: 'tortoise-hare', wordEn: 'tortoise', wordEs: 'tortuga', phonetic: '/ˈtɔːrtəs/', exampleSentence: 'The tortoise walked slowly.', exampleTranslation: 'La tortuga caminaba lentamente.', isHighlighted: true),
      VocabularyWord(wordId: 'th-v2', storyId: 'tortoise-hare', wordEn: 'hare', wordEs: 'liebre', phonetic: '/heər/', exampleSentence: 'The hare ran very fast.', exampleTranslation: 'La liebre corría muy rápido.', isHighlighted: true),
      VocabularyWord(wordId: 'th-v3', storyId: 'tortoise-hare', wordEn: 'race', wordEs: 'carrera', phonetic: '/reɪs/', exampleSentence: 'They had a race.', exampleTranslation: 'Tuvieron una carrera.', isHighlighted: true),
      VocabularyWord(wordId: 'th-v4', storyId: 'tortoise-hare', wordEn: 'fast', wordEs: 'rápido', phonetic: '/fɑːst/', exampleSentence: 'The hare was very fast.', exampleTranslation: 'La liebre era muy rápida.', isHighlighted: true),
      VocabularyWord(wordId: 'th-v5', storyId: 'tortoise-hare', wordEn: 'slow', wordEs: 'lento', phonetic: '/sləʊ/', exampleSentence: 'The tortoise was slow.', exampleTranslation: 'La tortuga era lenta.', isHighlighted: true),
      VocabularyWord(wordId: 'th-v6', storyId: 'tortoise-hare', wordEn: 'win', wordEs: 'ganar', phonetic: '/wɪn/', exampleSentence: 'The tortoise won the race.', exampleTranslation: 'La tortuga ganó la carrera.', isHighlighted: true),
    ],
    'twinkle-twinkle': [
      VocabularyWord(wordId: 'tt-v1', storyId: 'twinkle-twinkle', wordEn: 'star', wordEs: 'estrella', phonetic: '/stɑːr/', exampleSentence: 'The little star twinkles.', exampleTranslation: 'La estrellita brilla.', isHighlighted: true),
      VocabularyWord(wordId: 'tt-v2', storyId: 'twinkle-twinkle', wordEn: 'sky', wordEs: 'cielo', phonetic: '/skaɪ/', exampleSentence: 'The star is in the sky.', exampleTranslation: 'La estrella está en el cielo.', isHighlighted: true),
      VocabularyWord(wordId: 'tt-v3', storyId: 'twinkle-twinkle', wordEn: 'high', wordEs: 'alto', phonetic: '/haɪ/', exampleSentence: 'The star is high up.', exampleTranslation: 'La estrella está muy alta.', isHighlighted: true),
    ],
    'humpty-dumpty': [
      VocabularyWord(wordId: 'hd-v1', storyId: 'humpty-dumpty', wordEn: 'wall', wordEs: 'muro', phonetic: '/wɔːl/', exampleSentence: 'Humpty sat on a wall.', exampleTranslation: 'Humpty se sentó en un muro.', isHighlighted: true),
      VocabularyWord(wordId: 'hd-v2', storyId: 'humpty-dumpty', wordEn: 'fall', wordEs: 'caída', phonetic: '/fɔːl/', exampleSentence: 'Humpty had a great fall.', exampleTranslation: 'Humpty tuvo una gran caída.', isHighlighted: true),
      VocabularyWord(wordId: 'hd-v3', storyId: 'humpty-dumpty', wordEn: 'king', wordEs: 'rey', phonetic: '/kɪŋ/', exampleSentence: "The king's men came.", exampleTranslation: 'Los hombres del rey vinieron.', isHighlighted: true),
    ],
    'itsy-bitsy-spider': [
      VocabularyWord(wordId: 'ibs-v1', storyId: 'itsy-bitsy-spider', wordEn: 'spider', wordEs: 'araña', phonetic: '/ˈspaɪdər/', exampleSentence: 'The spider climbed up.', exampleTranslation: 'La araña subió.', isHighlighted: true),
      VocabularyWord(wordId: 'ibs-v2', storyId: 'itsy-bitsy-spider', wordEn: 'rain', wordEs: 'lluvia', phonetic: '/reɪn/', exampleSentence: 'Down came the rain.', exampleTranslation: 'Vino la lluvia.', isHighlighted: true),
      VocabularyWord(wordId: 'ibs-v3', storyId: 'itsy-bitsy-spider', wordEn: 'sun', wordEs: 'sol', phonetic: '/sʌn/', exampleSentence: 'Out came the sun.', exampleTranslation: 'Salió el sol.', isHighlighted: true),
    ],
    'anansi-spider': [
      VocabularyWord(wordId: 'as-v1', storyId: 'anansi-spider', wordEn: 'spider', wordEs: 'araña', phonetic: '/ˈspaɪdər/', exampleSentence: 'Anansi was a spider.', exampleTranslation: 'Anansi era una araña.', isHighlighted: true),
      VocabularyWord(wordId: 'as-v2', storyId: 'anansi-spider', wordEn: 'share', wordEs: 'compartir', phonetic: '/ʃeər/', exampleSentence: 'He did not want to share.', exampleTranslation: 'Él no quería compartir.', isHighlighted: true),
      VocabularyWord(wordId: 'as-v3', storyId: 'anansi-spider', wordEn: 'tree', wordEs: 'árbol', phonetic: '/triː/', exampleSentence: 'He climbed a tall tree.', exampleTranslation: 'Subió un árbol alto.', isHighlighted: true),
      VocabularyWord(wordId: 'as-v4', storyId: 'anansi-spider', wordEn: 'food', wordEs: 'comida', phonetic: '/fuːd/', exampleSentence: 'The village had food for everyone.', exampleTranslation: 'El pueblo tuvo comida para todos.', isHighlighted: true),
    ],
    'three-wishes': [
      VocabularyWord(wordId: 'tw-v1', storyId: 'three-wishes', wordEn: 'wish', wordEs: 'deseo', phonetic: '/wɪʃ/', exampleSentence: 'The bird gave him three wishes.', exampleTranslation: 'El pájaro le dio tres deseos.', isHighlighted: true),
      VocabularyWord(wordId: 'tw-v2', storyId: 'three-wishes', wordEn: 'food', wordEs: 'comida', phonetic: '/fuːd/', exampleSentence: 'They wished for food.', exampleTranslation: 'Pidieron comida.', isHighlighted: true),
      VocabularyWord(wordId: 'tw-v3', storyId: 'three-wishes', wordEn: 'gold', wordEs: 'oro', phonetic: '/ɡəʊld/', exampleSentence: 'They asked for gold.', exampleTranslation: 'Pidieron oro.', isHighlighted: true),
      VocabularyWord(wordId: 'tw-v4', storyId: 'three-wishes', wordEn: 'happy', wordEs: 'feliz', phonetic: '/ˈhæpi/', exampleSentence: 'They lived happily ever after.', exampleTranslation: 'Vivieron felices para siempre.', isHighlighted: true),
    ],
  };

  // ============================================================
  // PREGUNTAS DE COMPRENSIÓN (localizadas al español para under 6)
  // ============================================================
  static Map<String, List<ComprehensionQuestion>> get storyQuestions => {
    'little-red-riding-hood': [
      ComprehensionQuestion(questionId: 'lrh-q1', storyId: 'little-red-riding-hood', questionText: '¿Quién salvó a Caperucita Roja del lobo?', options: ['Su mamá', 'Un cazador', 'La abuela', 'Un amigo'], correctIndex: 1, explanation: 'Un cazador escuchó su grito y vino a salvarla del lobo.'),
    ],
    'three-little-pigs': [
      ComprehensionQuestion(questionId: 'tlp-q1', storyId: 'three-little-pigs', questionText: '¿Por qué el lobo no pudo tirar la casa de ladrillos?', options: ['El lobo estaba cansado', 'Los ladrillos son muy pesados', 'La casa era muy chiquita', 'Los cerditos ayudaron'], correctIndex: 1, explanation: 'Los ladrillos son pesados y fuertes. El lobo no pudo soplarlos.'),
    ],
    'goldilocks': [
      ComprehensionQuestion(questionId: 'g-q1', storyId: 'goldilocks', questionText: '¿De quién eran las gachas que se comió Ricitos de Oro?', options: ['Papá Oso', 'Mamá Osa', 'Bebé Oso', 'Las suyas'], correctIndex: 2, explanation: 'Las gachas de Bebé Oso estaban perfectas, así que se las comió todas.'),
    ],
    'ugly-duckling': [
      ComprehensionQuestion(questionId: 'ud-q1', storyId: 'ugly-duckling', questionText: '¿En qué se convirtió el patito feo?', options: ['Un pato grande', 'Un hermoso cisne', 'Un ganso', 'Un pollo'], correctIndex: 1, explanation: '¡Nunca fue feo! Era un cisne desde el principio. En primavera vio su reflejo.'),
    ],
    'tortoise-hare': [
      ComprehensionQuestion(questionId: 'th-q1', storyId: 'tortoise-hare', questionText: '¿Por qué ganó la tortuga la carrera?', options: ['Corrió más rápido', 'La liebre se perdió', 'Nunca se detuvo, la liebre dormía', 'La liebre la ayudó'], correctIndex: 2, explanation: 'La liebre tomó una siesta porque iba ganando. La tortuga siguió caminando y ganó!'),
    ],
    'twinkle-twinkle': [
      ComprehensionQuestion(questionId: 'tt-q1', storyId: 'twinkle-twinkle', questionText: '¿Qué brilla en el cielo?', options: ['El sol', 'La estrella', 'La luna', 'La nube'], correctIndex: 1, explanation: 'La canción habla de una estrellita que brilla en el cielo.'),
    ],
    'humpty-dumpty': [
      ComprehensionQuestion(questionId: 'hd-q1', storyId: 'humpty-dumpty', questionText: '¿Dónde se sentó Humpty Dumpty?', options: ['En una silla', 'En un muro', 'En el piso', 'En una cama'], correctIndex: 1, explanation: 'Humpty Dumpty se sentó en un muro alto.'),
    ],
    'itsy-bitsy-spider': [
      ComprehensionQuestion(questionId: 'ibs-q1', storyId: 'itsy-bitsy-spider', questionText: '¿Qué lavó a la araña afuera?', options: ['El viento', 'La lluvia', 'El sol', 'El agua'], correctIndex: 1, explanation: 'Vino la lluvia y lavó a la arañita afuera del desagüe.'),
    ],
    'anansi-spider': [
      ComprehensionQuestion(questionId: 'as-q1', storyId: 'anansi-spider', questionText: '¿Qué aprendió Anansi al final?', options: ['A ser travieso', 'Que compartir es mejor', 'A trepar árboles', 'A tener frijoles'], correctIndex: 1, explanation: 'Anansi aprendió que compartir es mejor que guardar todo para uno mismo.'),
    ],
    'three-wishes': [
      ComprehensionQuestion(questionId: 'tw-q1', storyId: 'three-wishes', questionText: '¿Cuál fue el mejor deseo?', options: ['Comida', 'Oro', 'Felicidad', 'Una casa'], correctIndex: 2, explanation: 'El tercer deseo, felicidad, fue el mejor de todos. Vivieron felices para siempre.'),
    ],
  };

  // ============================================================
  // TIMESTAMPS (generados automáticamente)
  // ============================================================
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
        final wordDuration = 400;
        timestamps.add(AudioTimestamp(word: word, startMs: currentMs, endMs: currentMs + wordDuration));
        currentMs += wordDuration;
      }
      map[storyId] = AudioTimestamps(timestamps: timestamps);
    }
    return map;
  }

  // ============================================================
  // LOGROS (rediseñados: eliminadas rachas de días para under 6)
  // ============================================================
  static const List<Achievement> achievements = [
    Achievement(achievementId: 'first_story', name: 'First Steps', description: 'Leíste tu primer cuento', iconUrl: '👶', emoji: '👶', criteriaType: 'stories_completed', criteriaThreshold: 1, xpReward: 10),
    Achievement(achievementId: 'stories_3', name: 'Curious Reader', description: 'Completaste 3 cuentos', iconUrl: '📖', emoji: '📖', criteriaType: 'stories_completed', criteriaThreshold: 3, xpReward: 20),
    Achievement(achievementId: 'stories_5', name: 'Bookworm', description: 'Completaste 5 cuentos', iconUrl: '📚', emoji: '📚', criteriaType: 'stories_completed', criteriaThreshold: 5, xpReward: 25),
    Achievement(achievementId: 'stories_10', name: 'Story Explorer', description: 'Completaste 10 cuentos', iconUrl: '🧭', emoji: '🧭', criteriaType: 'stories_completed', criteriaThreshold: 10, xpReward: 50),
    Achievement(achievementId: 'words_10', name: 'Word Collector', description: 'Aprendiste 10 palabras nuevas', iconUrl: '🔤', emoji: '🔤', criteriaType: 'words_learned', criteriaThreshold: 10, xpReward: 20),
    Achievement(achievementId: 'words_25', name: 'Word Master', description: 'Aprendiste 25 palabras nuevas', iconUrl: '🎯', emoji: '🎯', criteriaType: 'words_learned', criteriaThreshold: 25, xpReward: 40),
    Achievement(achievementId: 'categories_2', name: 'Explorer', description: 'Exploraste 2 categorías diferentes', iconUrl: '🗺️', emoji: '🗺️', criteriaType: 'categories_explored', criteriaThreshold: 2, xpReward: 15),
    Achievement(achievementId: 'categories_4', name: 'World Traveler', description: 'Exploraste 4 categorías diferentes', iconUrl: '🌍', emoji: '🌍', criteriaType: 'categories_explored', criteriaThreshold: 4, xpReward: 35),
    Achievement(achievementId: 'time_30_min', name: 'Time Traveler', description: 'Leíste por 30 minutos en total', iconUrl: '⏰', emoji: '⏰', criteriaType: 'time_spent_minutes', criteriaThreshold: 30, xpReward: 25),
    Achievement(achievementId: 'nursery_3', name: 'Singer', description: 'Cantaste 3 canciones infantiles', iconUrl: '🎵', emoji: '🎵', criteriaType: 'nursery_rhymes_completed', criteriaThreshold: 3, xpReward: 30),
  ];

  // ============================================================
  // STATS INICIALES (corregidas: words_learned ahora es real)
  // ============================================================
  static ReadingStats get initialStats => const ReadingStats(
    storiesCompleted: 2,
    storiesStarted: 3,
    totalMinutes: 8,
    wordsLearned: 12,
    currentStreak: 0,
    longestStreak: 0,
    categoriesExplored: 2,
    achievementsUnlocked: 1,
    lastReadDate: null,
  );
}
