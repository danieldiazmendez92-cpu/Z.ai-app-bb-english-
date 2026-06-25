# Informe de Revisión Pedagógica — StoryEnglish Kids

**Revisora**: Dra. María Fernández
**Especialista en**: Enseñanza de Inglés para Niños (1-7 años)
**Credenciales**: PhD en Educación Infantil (Universidad de Barcelona), CELTA-Pe (Cambridge), ex-profesora British Council Early Years, autora de 3 libros sobre adquisición temprana de segundas lenguas
**Fecha**: 2026-06-25
**Versión de la app**: Pre-launch (commit actual — demo_data.dart)

---

## Resumen Ejecutivo

StoryEnglish Kids es un producto **técnicamente sólido y bien intencionado**, construido sobre una pila moderna (Flutter + Firebase + Gemini + TTS) y con una arquitectura pensada para escalar. El equipo logró algo importante: la experiencia central — audio sincronizado con resaltado palabra-a-palabra — es **la feature pedagógica más valiosa** de la app y está correctamente implementada. El modelo de datos contempla los componentes correctos (cuento, secciones, vocabulario, preguntas, logros) y el documento de accesibilidad (`10-accessibility.md`) muestra sensibilidad hacia inclusión.

Dicho esto, **el contenido pedagógico real del demo (`demo_data.dart`) tiene problemas serios** que deben corregirse antes de publicar. Los más graves son: (1) **errores gramaticales en el inglés fuente** (omisión de posesivos en 4 de los 5 cuentos: *"grandmother house"*, *"Papa porridge"*, *"brother wood house"*, *"Baby chair"*); (2) **el rango 2-7 años es pedagógicamente inmanejable** con una sola experiencia de producto — los toddlers (2-3) y los lectores principiantes (6-7) requieren UX diametralmente opuestas; (3) **las preguntas de comprensión están solo en inglés**, lo que las hace inaccesibles para niños de 4-5 años no lectores; (4) el cálculo de `words_learned` es **una métrica falsa** (`storiesCompleted * 8`) que va a desinformar a los padres y a falsear los logros; (5) el sistema de logros basado en **rachas de días (3, 7, 30) es inadecuado y potencialmente contraproducente para menores de 6 años**.

Mi veredicto es **🟡 LANZAR CON CONDICIONES**: la app no debe publicarse tal como está, pero los cambios críticos son acotados (estimados en 2-4 semanas de trabajo de contenido + 1 semana de UX). La base técnica y de diseño es buena; lo que falta es **rigor pedagógico en el contenido y diferenciación por edad**. Con los ajustes que detallo abajo, StoryEnglish Kids puede convertirse en una app genuinamente útil para familias hispanohablantes.

Agradezco al equipo el trabajo hecho — sé que construir una app educativa para niños es mucho más difícil que una app para adultos, y lo que veo demuestra compromiso serio. Este informe busca pulir un diamante que ya tiene forma.

---

## 1. Adecuación por edad

El rango **2-7 años** declarado en la app es **pedagógicamente inmanejable como experiencia única**. Estos seis años abarcan tres sub-etapas evolutivas con capacidades cognitivas, lingüísticas y atencionales radicalmente distintas. Tratarlas como un solo perfil de usuario es el error estructural más importante del producto.

### 1.1 Sub-etapas evolutivas y lo que cada una necesita

| Edad | Etapa | L1 (español) | Capacidad EN | Atención | Lectura | Lo que necesitan de la app |
|------|-------|--------------|--------------|----------|---------|-----------------------------|
| **2-3** | Toddler / pre-literato | En consolidación | Cero o cercano a cero | 2-4 min por actividad | No lee | Input oral masivo, canciones, rimas, repetición extrema, ilustraciones grandes, **interacción con un adulto presente** |
| **4-5** | Pre-K, emergent literacy | Consolidada | Palabras sueltas, frases cortas | 5-10 min | Reconoce letras, no decodifica | Cuentos cortos narrados, vocabulario concreto (Tier 1), repetición de patrones, preguntas en español con opción de switch a EN |
| **6-7** | Early reader | Fluida | Frases simples | 10-15 min | Lectura emergente (decodifica con apoyo) | Texto visible con audio sync (lo que ya hace la app), vocabulario Tier 1-2, preguntas de comprensión en EN con apoyo visual |

### 1.2 Hallazgos críticos por sub-etapa

**Para 2-3 años (toddlers):**
- El cuento *Tortoise and Hare* está etiquetado `minAge: 2` — esto es **inapropiado**. La AAP (American Academy of Pediatrics) y la OPS recomiendan **evitar pantallas estructuradas antes de los 24 meses** salvo videollamadas, y entre 2-5 años limitar a 1 hora/día de contenido **co-usado con un adulto**. Un cuento de 3 minutos con texto resaltado en inglés no es la actividad adecuada para un toddler que apenas está consolidando su L1.
- A esta edad, **el input oral masivo con adulto presente** (canciones, rimas, naming) es lo que produce adquisición (Kuhl, 2004; Weisleder & Fernald, 2013). Una app sola no reemplaza eso — y debemos ser honestos con los padres al respecto.
- **Recomendación**: o bien **eliminar `minAge: 2`** y empezar en 3 (preferido), o desarrollar una sección dedicada "Toddler Time" con nursery rhymes, sin texto visible, sin preguntas de comprensión, co-uso parental obligatorio.

**Para 4-5 años (pre-K):**
- Los cuentos actuales (longitud ~80-100 palabras en 3 secciones) son **razonablemente adecuados en extensión** para 4-5 años si se narran a velocidad normal (~3-4 min). Bien.
- **Las preguntas de comprensión en inglés son inaccesibles**: un niño de 4-5 años hispanohablante **no decodifica inglés escrito**, y aunque escuche la pregunta, vocabulario como *"saved"*, *"couldn't blow down"*, *"porridge"*, *"become"* está por encima de su nivel. Resultado predecible: el niño taptea al azar, recibe feedback rojo/verde sin entender por qué. Esto es **anti-pedagógico** y puede generar aversión a la app.
- **Las preguntas tipo "por qué"** (TLP, Tortoise & Hare) **requieren razonamiento causal abstracto** que recién se consolida hacia los 6-7 años (Piaget, teoría del desarrollo cognitivo). Para 4-5 deben ser preguntas literales de reconocimiento ("Who...", "What...").

**Para 6-7 años (early readers):**
- El nivel de los cuentos es **adecuado o incluso algo fácil** para esta edad, lo cual es bueno para input comprensible (Krashen's *i+1*).
- **El resaltado palabra-a-palabra sincronizado con audio es excelente** para esta etapa: apoya el mapeo grafema-fonema, núcleo de la lectura emergente. Es probablemente la feature más valiosa de la app.
- Las preguntas de comprensión funcionan mejor aquí, pero **siguen siendo solo 1 por cuento** cuando el modelo de datos (`04-firestore-schema.md`) y el documento de arquitectura dicen 3-5. Falta consistencia.
- **Velocidad 1.5x** en el selector de audio no tiene sentido pedagógico para esta edad: leer a 1.5x reduce comprensión. Sugiero reemplazar por 0.75x, 1.0x, 1.25x máximo.

### 1.3 Recomendación estructural

**Diferenciar el producto por edad en tres modos**, configurables en el perfil del niño:

| Modo | Edad | UX |
|------|------|----|
| **Listen & Play** | 2-3 | Sin texto visible, solo ilustración grande + audio + canto. Sin preguntas. Co-uso parental sugerido en pantalla. |
| **Read With Me** | 4-5 | Texto en inglés visible, resaltado sincronizado (lo actual), traducción on-by-default, vocabulario popup con audio, **pregunta de comprensión en español con opción de escuchar en inglés**. |
| **Read Myself** | 6-7 | Texto en inglés visible (lo actual), traducción off-by-default, **3 preguntas de comprensión en inglés** con feedback de retry. |

Esto se puede lograr con flags en `ChildProfile` (campo `mode` o derivado de `age`) sin rediseñar la app.

---

## 2. Análisis de los 5 cuentos del demo

### 2.1 Little Red Riding Hood

- **Edad recomendada en app**: 4-7
- **Duración**: 5 min (3 secciones, ~80 palabras)
- **Mi evaluación de edad**: 5-7 años (no 4). El contenido (lobo que quiere comerse a la niña y a la abuela, disfrazarse, "aprendió la lección") es temáticamente complejo para 4 años.

**Texto en inglés — issues**:
- 🚨 **Error gramatical CRÍTICO**: *"I am going to my grandmother house"* → debe ser *"my grandmother's house"*. El posesivo sajón es **exactamente** lo que un niño de 4-7 años debe aprender en esta etapa, y aquí se le enseña mal. Es lo opuesto a input comprensible: es input defectuoso.
- *"The wolf dressed as grandmother"* — sonaría más natural *"The wolf dressed up as grandmother"* o *"disguised himself as grandmother"*.
- *"A hunter heard her scream and saved the day"* — "saved the day" es un idiom; para input de principiantes conviene algo más literal como *"saved her"*.
- *"learned her lesson"* — frase hecha, abstracta para 4-5 años.

**Traducción al español**:
- Generalmente fiel y natural. "Caperucita Roja" correcto.
- "El lobo se disfrazó de abuela" — correcto.
- "salvó el día" — calco del inglés; en español infantil más natural: "salvó a Caperucita" o "los salvó".

**Vocabulario (4 palabras)**:
- *forest* /bosque/ — útil, frecuente, bien elegido.
- *wolf* /lobo/ — buenísima elección, se repite en TLP (clave para inter-conexión léxica).
- *grandmother* /abuela/ — útil pero fonéticamente complejo (`/ˈɡrænmʌðər/`) para 4-5 años; quizás *grandma* es más apropiado para esta edad.
- *basket* /canasta/ — **elección débil**: palabra de frecuencia baja, no es transferible a otros contextos cotidianos del niño. Mejor: *mother* /madre/, *house* /casa/, *red* /rojo/ (¡es Caperucita ROJA y nunca se menciona el color!).
- IPA `/ˈfɒrɪst/` es **pronunciación británica**; para audiencia hispanoamericana sería más útil `/ˈfɔːrɪst/` (US) o mostrar ambas.

**Pregunta de comprensión**:
- *"Who saved Little Red Riding Hood from the wolf?"* — opciones: *Her mother / A hunter / The grandmother / A friend*.
- **Solo en inglés** — inaccesible para 4-5 no lectores. Para 6-7 es adecuada.
- Es pregunta de **recall literal**, lo cual está bien para la edad, pero **no mide comprensión del lenguaje**, solo memoria de hechos. Una pregunta más valiosa sería de vocabulario: *"What color is Riding Hood's hood?"* (red) o *"Where does grandmother live?"* (in the forest).

**Potencial de engagement**: alto. Es un cuento universalmente amado. La ilustración de emojis (👧🐺👶) es **insuficiente** — los emojis no transmiten escena narrativa. Para esta edad hacen falta ilustraciones reales.

**Issues adicionales**:
- "Quería comerse a las dos" — contenido sensible pero **aceptable** en versión suavizada. Algunos padres pueden objetar; sugerimos disclaimer parental en cuentos con antagonistas.
- El desenlace omite que el lobo es derrotado definitivamente ("ran away"), lo cual suaviza la violencia original. Bien.

---

### 2.2 The Three Little Pigs

- **Edad recomendada en app**: 3-7
- **Duración**: 4 min (3 secciones, ~90 palabras)
- **Mi evaluación de edad**: 4-7. Para 3 años, *"huffed and puffed and blew the straw house down"* es una carga atencional y léxica excesiva.

**Texto en inglés — issues**:
- 🚨 **Error gramatical CRÍTICO**: *"The first pig ran to his brother wood house"* → debe ser *"his brother's wood house"* (posesivo sajón omitido).
- *"He huffed and puffed and blew the straw house down!"* — frase icónica, excelente para aprendizaje por repetición ritual. Mantener.
- *"Both pigs ran to the brick house"* — bien.
- *"the pigs made a fire"* — algo ambiguo; más claro: *"the pigs lit a fire under the chimney"*.

**Traducción al español**:
- "Sopló y sopló" — excelente, mantiene la repetición rítmica del original, clave para este cuento.
- "los cerditos hicieron fuego" — en español infantil más natural: *"los cerditos le prendieron fuego debajo"* o *"encendieron un fuego"*.

**Vocabulario (3 palabras)**:
- *straw* /paja/ — frecuencia baja fuera de este cuento. Defendible por contexto, pero poco transferible.
- *brick* /ladrillo/ — útil pero concreto y bajo.
- *wolf* /lobo/ — excelente, refuerza la palabra aprendida en LRRH (inter-conexión léxica).
- **Faltan palabras clave y de mayor valor**: *pig* (¡la palabra más importante del cuento y no está destacada!), *house* (palabra de altísima frecuencia), *big/bad* (adjetivos opuestos básicos). Sugiero **expandir a 5-6 palabras** incluyendo las anteriores.

**Pregunta de comprensión**:
- *"Why couldn't the wolf blow down the brick house?"* — opciones: *The wolf was tired / Bricks are too heavy / The house was too small / The pigs helped*.
- 🚨 **Pregunta tipo "por qué"** inadecuada para menores de 6 años (requiere razonamiento causal abstracto).
- 🚨 **La respuesta correcta (*"Bricks are too heavy"*) es factualmente cuestionable** como razón única — la verdadera razón es que los ladrillos pegados con cemento forman una estructura sólida, no solo el peso. Para un niño pequeño, mejor: *"Because brick houses are very strong"*.

**Potencial de engagement**: muy alto. La repetición "huffed and puffed" es mágica para niños pequeños.

---

### 2.3 Goldilocks and the Three Bears

- **Edad recomendada en app**: 3-6
- **Duración**: 4 min (3 secciones, ~85 palabras)
- **Mi evaluación de edad**: 4-6. Adecuado.

**Texto en inglés — issues** (este cuento tiene **la mayor concentración de errores gramaticales**):
- 🚨 🚨 🚨 **Cinco errores de posesivo sajón** en una sola sección:
  - *"Papa porridge was too hot"* → *"Papa Bear's porridge was too hot"*
  - *"Mama porridge was too cold"* → *"Mama Bear's porridge was too cold"*
  - *"Baby porridge was just right"* → *"Baby Bear's porridge was just right"*
  - *"Goldilocks sat in the bears chairs"* → *"the bears' chairs"* (o mejor *"the bears' chairs"*)
  - *"the baby chair"* → *"Baby Bear's chair"*
  - *"the baby bed"* → *"Baby Bear's bed"*
- Este cuento **debería ser el mejor ejemplo para enseñar posesivo** (es literalmente "la silla de Mamá Osa, la silla de Papá Oso..."). En cambio, enseña mal.
- *"She tasted the porridge"* — bien.
- *"slept in the baby bed"* — mejor *"sleeping"* o *"lay down in"*.

**Traducción al español**:
- "Las de Papá estaban muy calientes. Las de Mamá estaban muy frías." — **buena traducción**, preserva la estructura paralela. Una pena que el original inglés no la preserve igual con sus posesivos.
- "Ricitos de Oro" — correcto, universal.
- "se las comió todas" — natural.

**Vocabulario (2 palabras)**:
- *porridge* /gachas/ — 🚨 **palabra de bajísima frecuencia**, arcaica para niños modernos, y traducida como "gachas" que también es bajo-frecuencia en español infantil latinoamericano. Mejor reemplazar por *oatmeal* o, mejor aún, **ampliar el vocabulario**.
- *bears* /osos/ — útil pero **plurales son más difíciles que singulares** para principiantes. Mejor *bear* /oso/.
- **Solo 2 palabras es insuficiente** para un cuento de 3 secciones. Faltan: *hot/cold/just right* (los adjetivos clave del cuento), *chair, bed, soup/food, little/big*. Este cuento es **una mina de oro para vocabulario de adjetivos opuestos** y no se aprovecha.

**Pregunta de comprensión**:
- *"Whose porridge did Goldilocks eat?"* — opciones: *Papa Bear / Mama Bear / Baby Bear / Her own*. Correcta: Baby Bear.
- Pregunta de recall literal, **adecuada para 4-6 años** si estuviera en español. En inglés es inaccesible.
- Buena pregunta porque obliga a recordar la estructura repetitiva del cuento.

**Potencial de engagement**: alto. La estructura repetitiva (Papa/Mama/Baby × porridge/chair/bed) es **perfecta para pre-K** — favorece anticipación, participación coral y memoria. Lástima que el vocabulario no aproveche esto.

---

### 2.4 The Ugly Duckling

- **Edad recomendada en app**: 5-7
- **Duración**: 6 min (3 secciones, ~95 palabras)
- **Mi evaluación de edad**: 5-7. Adecuado. El tema emocional (rechazo, soledad, llanto "en las noches oscuras") es pesado para menores de 5.

**Texto en inglés — issues**:
- *"Six pretty ducklings came out"* — bien.
- *"How ugly!" said the other ducks* — modela **lenguaje de bullying** que el niño puede replicar. Sugiero añadir contexto parental o cambiar a *"This one looks different"*.
- *"He ran away from home"* — abandono infantil, tema sensible.
- *"He cried many tears in the dark nights"* — tono melancólico intenso para 5 años. Considerar suavizar a *"He felt very sad and alone all winter"*.
- *"He was not ugly at all"* — bien.
- *"The other swans welcomed him"* — excelente cierre, modelo de inclusión.

**Traducción al español**:
- 🚨 *"eclosionaron"* — **palabra académica**, no usada en español infantil. Los niños de 5 años no la conocen. Reemplazar por *"se abrieron los huevos"* o *"rompieron el cascarón"* o, simplemente, *"nacieros"*.
- "mamá pata" — correcto y natural.
- "se fue de casa" — correcto, pero "se escapó de casa" capta mejor el matiz de huida.
- "Lloró muchas lágrimas en las noches oscuras" — fiel pero intenso.

**Vocabulario (2 palabras)**:
- *duckling* /patito/ — útil, diminitivo enseñable.
- *swan* /cisne/ — útil, palabra concreta.
- 🚨 **Solo 2 palabras para un cuento de 6 minutos es insuficiente**. Faltan: *ugly* /feo/ y *beautiful* /hermoso/ (par antonímico clave), *duck* /pato/, *winter* /invierno/, *spring* /primavera/ (conceptos temporales).

**Pregunta de comprensión**:
- *"What did the ugly duckling become?"* — opciones: *A big duck / A beautiful swan / A goose / A chicken*.
- Pregunta de recall, **adecuada para 5-7 años**.
- El distractor "A big duck" es excelente porque evalúa si el niño distinguió duck/swan.
- En inglés sigue siendo inaccesible para 5 años no lectores.

**Potencial de engagement**: medio. El tema es más triste que los otros cuentos; algunos niños pueden no querer repetirlo. Sugiero etiquetar con advertencia temática para padres.

**IPA**: `/swɒn/` es británica; la US es `/swɑːn/`.

---

### 2.5 The Tortoise and the Hare

- **Edad recomendada en app**: 2-6
- **Duración**: 3 min (3 secciones, ~75 palabras)
- **Mi evaluación de edad**: 🚨 **Mínimo 4 años**, no 2. A los 2 años un niño no debe usar apps de cuentos estructurados en L2 sin co-uso adulto intenso, y la pregunta de comprensión es inaccesible para esa edad.

**Texto en inglés — issues**:
- *"You are so slow!" said the hare* — modela burla. Defendible por la trama, pero conviene añadir contrapunto explícito ("The tortoise did not get angry").
- *"Let us have a race!"* — correcto, aunque en inglés moderno más común *"Let's have a race"*. Para input infantil, las contracciones son más naturales.
- *"I will take a little nap"* — bien.
- *"She walked and walked"* — excelente, repetición ritual útil para adquisición.
- *"Slow and steady wins the race"* — frase icónica, idiomática; defensa: vale la pena enseñar como "frase-hecha".
- *"The hare learned his lesson"* — misma frase-hecha que en LRRH, algo abstracta para menores de 5.

**Traducción al español**:
- 🚨 *"rió y rió"* — **error**: en español el verbo es pronominal. Debe ser *"se rió y se rió"* o *"se rió mucho"*.
- *"Hagamos una carrera"* — correcto.
- *"Lento pero constante gana la carrera"* — buena traducción, aunque "paso a paso" o "despacio pero sin parar" son alternativas más infantiles.
- *"La liebre aprendió su lección"* — calco del inglés, algo literal.

**Vocabulario (3 palabras)**:
- *tortoise* /tortuga/ — útil, aunque fonéticamente complejo (`/ˈtɔːrtəs/`).
- *hare* /liebre/ — 🚨 palabra de **baja frecuencia incluso en español**; "liebre" no es palabra que un niño latinoamericano escuche. *Rabbit* /conejo/ sería más útil, aunque no es exactamente lo mismo. Si se mantiene *hare*, al menos añadir una imagen clara.
- *race* /carrera/ — útil, frecuente.
- Faltan: *fast* /rápido/, *slow* /lento/ (par antonímico central del cuento), *run* /correr/, *walk* /caminar/.

**Pregunta de comprensión**:
- *"Why did the tortoise win the race?"* — opciones: *She ran faster / The hare got lost / She never stopped, the hare napped / The hare helped her*.
- 🚨 Pregunta tipo "por qué" — **inadecuada para menores de 6 años**.
- La opción correcta es una oración larga con dos cláusulas, difícil de procesar para pre-lectores.

**Potencial de engagement**: medio-alto. La moraleja es clara y la repetición "walked and walked" funciona. Pero el cuento es más corto y menos dramático que los otros, lo que puede reducir re-lectura.

**IPA**: `/heər/` es la forma británica no rótica; la forma estadounidense es `/her/`. Para audiencia hispanoamericana (donde la influencia del inglés es mayoritariamente US), usar US.

---

## 3. Metodología de enseñanza

El enfoque general — **input audiovisual sincronizado + vocabulario destacado + pregunta de comprensión** — está bien inspirado en el modelo de Input Comprensible de Krashen y en el enfoque Whole Story para storytelling en L2 (Cameron, 2001; Wright, 1995). Sin embargo, hay **gaps metodológicos importantes**.

### 3.1 Lo que está bien

- ✅ **Input comprensible vía audio + ilustración**: la narración sincronizada con texto resaltado es la mejor herramienta digital existente para pre-lectores en L2 (Vaughn et al., 2010; Block et al., 2009 sobre bimodal input).
- ✅ **Traducción opcional (toggle)**: bien diseñada — permitemodo "input solo en EN" (Krashen puro) o modo "bilingüe con apoyo" (Cummins).
- ✅ **Vocabulario en contexto**: las palabras destacadas se enseñan dentro del cuento, no como listas aisladas. Esto sigue el principio de aprendizaje léxico contextualizado (Nation, 2001).
- ✅ **Control de velocidad de audio (0.75x disponible)**: excelente para principiantes.
- ✅ **Preguntas de comprensión al final**: estructura coherente.

### 3.2 Lo que falta o está mal

❌ **No hay repetición espaciada (Spaced Repetition System, SRS)**. Las palabras destacadas se ven una sola vez, en un cuento, y nunca se revisitan sistemáticamente. Esto viola el principio de distribución óptima del aprendizaje (Bjork, 1994; Cepeda et al., 2008). La investigación en adquisición léxica en L2 (Nation, 2001; Schmitt, 2010) recomienda entre **5-15 encuentros** con una palabra nueva en contextos variados antes de consolidarla. La app, tal cual está, ofrece **1-2 encuentros** (cuando aparece en el cuento + cuando se toca el popup).

  **Recomendación concreta**: implementar un algoritmo simple tipo Leitner a nivel de `vocabulary_word` global:
  - Día 1: palabra nueva en cuento (resaltada).
  - Día 2: pregunta de reconocimiento ("¿Cuál es *wolf*?" con 4 imágenes).
  - Día 5: palabra reaparece en otro cuento.
  - Día 14: pregunta de recall ("Tocá la palabra que significa 'lobo'").
  - Día 30: uso en producción (opcional: grabar al niño repitiendo).
  - Persistir `user_vocab_progress/{childId}/{wordId}` con campos: `encounters`, `last_seen`, `next_review`, `box_level`.

❌ **No hay producción (output)**. El niño solo recibe input. Si bien Krashen defiende que el input es suficiente, la investigación más reciente (Swain, 1985; 2005) muestra que la **producción forzada** (forced output) es necesaria para avanzar de BICS a CALP. No hay nada en la app que invite al niño a **repetir, nombrar, o producir**.
  **Recomendación**: añadir un botón "🎤 Repetir" en el `VocabularyPopup` que grabe al niño diciendo la palabra y opcionalmente haga speech recognition simple para feedback.

❌ **No hay multi-sensory**. Solo audio + texto (con emojis como pseudo-ilustraciones en el demo). Para pre-lectores, la investigación (Mayer, 2009; multisensory learning, Shams & Seitz, 2008) muestra que combinar modalidades (visual real + audio + gesto) duplica la retención. El modelo de datos contempla `imageUrl` en `VocabularyWord`, pero en el demo no se usa. **Recomendación**: agregar imagen ilustrativa real (no emoji) para cada palabra destacada.

❌ **El progreso del niño es mal medido**. La métrica `wordsLearned` se calcula como `storiesCompleted * 8` (`achievement_repository_impl.dart` línea 160). Esto es una **falsa medición**: completar un cuento no implica haber aprendido ninguna palabra. Si la app va a decirle a los padres "tu hijo aprendió 50 palabras", **esa afirmación debe ser verdadera**. Si no, es marketing engañoso y un fraude pedagógico.
  **Recomendación CRÍTICA**: implementar `user_vocab_progress` real y calcular `wordsLearned` como `count where box_level >= 3` (palabras vistas al menos 3 veces con reconocimiento correcto).

❌ **Solo 1 pregunta de comprensión por cuento**, cuando el documento `04-firestore-schema.md` y la lógica de ingesta con Gemini prevén 3-5. Esto reduce drásticamente el valor evaluativo. **Recomendación**: generar 3 preguntas por cuento (literal, inferencial, vocabulario) y mostrarlas escalonadas (1 para 4-5 años, 3 para 6-7).

❌ **No hay andamiaje entre cuentos**. Cada cuento es una isla. La investigación en storytelling para L2 (Cameron, 2001) recomienda **thematic clustering** y **recurrencia léxica**: que las mismas palabras aparezcan en varios cuentos para permitir encuentros múltiples. La app lo hace bien con *wolf* (LRRH + TLP), pero no hay una planificación léxica sistemática.
  **Recomendación**: crear una "matriz léxica" de ~100 palabras de alta frecuencia (Tier 1) y asignar cuentos que las cubran, garantizando cada palabra aparezca en 3+ cuentos.

❌ **No hay feedback de producción ni corrección implícita**. El niño nunca produce, así que no hay nada que corregir — pero cuando se equivoca en la pregunta, el feedback es **una cruzada roja visual** (`Colors.red.withOpacity(0.1)` y `Icons.cancel, color: Colors.red` en `story_end_screen.dart`), lo cual **contradice el principio documentado** en `10-accessibility.md` (sección 7.3): *"no se le dice 'incorrecto'. Se le dice '¡Sigamos intentando!' y se le da otra oportunidad"*. El código actual **no ofrece otra oportunidad**: `_answered = true` bloquea el tap. Esto debe corregirse.

### 3.3 Las insignias: ¿motivan o sobre-estimulan?

El catálogo de logros (`achievement_repository_impl.dart` líneas 291-393) mezcla aciertos y riesgos:

✅ **Aciertos**:
- `first_story`, `stories_5`, `stories_10`, `stories_25`: apropiados, basados en hitos de actividad (no de desempeño). No frustran.
- `categories_3`: fomenta diversificación de lectura. Bien.
- `time_60_min`: hito razonable para 6-7 años.

🚨 **Riesgos**:
- `streak_3_days`, `streak_7_days`, `streak_30_days`: las **rachas son inadecuadas para menores de 6 años** y problemáticas hasta los 8. Razones:
  1. Los niños de 2-5 no tienen control sobre su agenda — si un día los padres están ocupados y no les toca la app, el niño "pierde" la racha sin haber hecho nada malo. Esto genera **frustración injusta**.
  2. Las rachas generan **ansiedad de continuidad** y fomentan uso compulsivo (patrón de diseño oscuro, *"dark pattern"*). La APA (2022) advierte sobre esto en apps infantiles.
  3. Para un niño de 4 años, "3 días seguidos" es un concepto temporal abstracto que no comprende.
  **Recomendación**: eliminar `streak_*` para perfiles con `age < 6`. Reemplazar por `read_3_days_this_week` (no consecutivos) o `story_a_week`.

- `words_50`: se basa en la métrica falsa `wordsLearned` (ver arriba). Si un niño completa 7 cuentos, gana el logro "Aprendiste 50 palabras nuevas" — pero la afirmación no está fundamentada. **Recomendación**: o se mide real (post-SRS), o se elimina.

- `perfect_comprehension` aparece como `criteriaType` en `achievement.dart` pero **no hay ningún logro que lo use**. Si se quiere fomentar comprensión, debería existir `comprehension_5_correct` (5 preguntas seguidas correctas).

- **Faltan logros de proceso, no de resultado**: `"Viste el mismo cuento 3 veces"` (re-lectura, clave para pre-K), `"Tocaste 10 palabras para ver su traducción"` (curiosidad léxica), `"Escuchaste un cuento a velocidad 0.75x"` (esfuerzo). Estos premian **comportamientos de aprendizaje** y no solo outputs.

---

## 4. UX pedagógica

### 4.1 El Reader (texto + resaltado sincronizado)

**Para pre-lectores (4-5)**: bien intencionado pero con riesgos.
- ✅ El resaltado palabra-a-palabra es **la mejor herramienta digital** para mapear sonido-grafía. Confirmado por investigación (Korat & Shamir, 2007; Verhallen et al., 2006).
- ✅ Tamaño de fuente 24sp con `height: 1.8` es legible y bien espaciado.
- 🚨 El texto visible en inglés para 4-5 años que no leen es **ruido visual** — no daña, pero no aporta. Debería haber un modo **"Listen Only"** para 4-5 donde el texto no se muestre (o se muestre solo al tocar una palabra), permitiendo foco en audio + ilustración.
- 🚨 La traducción está **off by default** (`_showTranslation = false`). Para 4-5 años principiantes debería estar **on by default** para garantizar comprensión (Cummins: input comprensible = input + contexto compartido).

**Para lectores principiantes (6-7)**: excelente.
- El resaltado sincronizado + traducción opcional + control de velocidad + navegación entre secciones es justo lo que esta etapa necesita. Bravo.
- 🚨 Velocidad **1.5x no debería existir** para esta edad (reduce comprensión, fomenta skimming). Reemplazar por 0.5x, 0.75x, 1.0x, 1.25x.

### 4.2 El popup de vocabulario

Bien diseñado (wordEn, IPA, wordEs, ejemplo). Issues:
- 🚨 **No hay botón de audio para escuchar la palabra**. Si el niño toca una palabra para "saber qué significa", lo mínimo es poder escucharla en voz alta aislada. El audio solo suena en el flujo del cuento. **Recomendación CRÍTICA**: añadir un botón 🔊 en `VocabularyPopup` que llame a Google TTS para esa palabra (cacheada en ingesta).
- 🚨 El IPA es **inútil para el niño** (no lee símbolos fonéticos) y **difícil para padres no-bilingües**. **Recomendación**: ocultar IPA por defecto; mostrarlo solo si el padre activa "Modo experto" en settings. Para padres no-bilingües, mejor un "read-as-Spanish" aproximado: *wolf → "güolf"* (sí, es una aproximación fea, pero ayuda).
- 🚨 El ejemplo de uso está **en inglés sin traducción visible por defecto** (sí la hay en el modelo, pero conviene siempre mostrarla para padres no-bilingües).

### 4.3 La pregunta de comprensión al final

**Issues críticos**:
- 🚨 Solo en inglés (ver sección 1 y 2).
- 🚨 No hay opción de **re-intento** después de errar — contradice el documento de accesibilidad. El código `story_end_screen.dart` línea 217 (`_selectAnswer`) setea `_answered = true` y deshabilita los taps.
- 🚨 Feedback visual usa `Colors.red` y `Icons.cancel` (cruz roja) — explícitamente **contradictorio** con el principio de "no decir incorrecto" declarado en `10-accessibility.md` sección 7.3. Aunque el texto no diga "incorrecto", el color y el ícono lo comunican.
- ✅ La explicación aparece al errar — buena práctica.

**Recomendaciones concretas**:
1. Reemplazar feedback rojo/cruz por un **color neutro + frase motivadora**: "¡Casi! Sigamos intentando" en color amarillo suave, con la opción de elegir de nuevo.
2. Implementar **2 reintentos**. Tras el 2do error, mostrar la respuesta correcta con la explicación y un emoji cálido (🤗).
3. Para 4-5 años: pregunta en español, opciones en inglés (modo "reconocimiento").
4. Para 6-7 años: pregunta en inglés, opciones en inglés (modo "comprensión").
5. Generar **3 preguntas** por cuento (no 1): 1 literal, 1 inferencial, 1 de vocabulario.

### 4.4 El diseño colorido y lúdico

No tengo acceso directo a los assets visuales finales, pero por la configuración de tema (`Theme.of(context).colorScheme.primary` con azul `#4A90E2`, emojis como ilustraciones) infiero:
- ✅ Paleta alegre, apropiada.
- ✅ Tap targets de 48-72dp (`IconButton` 32 + padding 12 = 44-56dp), marginalmente por debajo del recomendado 60dp para niños en `10-accessibility.md`. **Aumentar a 60dp mínimo**.
- 🚨 Las ilustraciones como emojis (👧🐺🐻) son **insuficientes para storytelling**. Un emoji de lobo no transmite "lobo grande y malo en el bosque". Para pre-lectores, la ilustración es **el 70% del input comprensible** (Mayer, 2009). Sin ilustraciones reales de calidad, el input comprensible de la app se desploma.
- 🚨 **Animación de celebración** (`TweenAnimationBuilder` con `Curves.elasticOut`) puede ser **sobre-estimulante** para algunos niños (en espectro autista, con TDAH). El modo simplificado (documentado en `10-accessibility.md` sección 7.1) debe respetarse.

---

## 5. Contenido sensible y diversidad

### 5.1 Análisis de contenido sensible

| Cuento | Contenido sensible | Severidad | Acción recomendada |
|--------|--------------------|-----------|---------------------|
| LRRH | Lobo quiere comerse a la niña y a la abuela; disfraz; "grito" | Media | Aceptar versión suavizada (lobo "escapa"). Añadir etiqueta `theme: ['mild-peril']` y filtro parental. |
| TLP | Lobo intenta bajar por chimenea, le prenden fuego | Media | Aceptar versión suavizada. Misma etiqueta. |
| Goldilocks | Niña entra a casa ajena, rompe cosas, huye | Baja | Aceptar. Oportunidad de diálogo parental sobre respeto a lo ajeno. |
| Ugly Duckling | Burla ("How ugly!"), rechazo, abandono ("ran away from home"), soledad, llanto | **Alta** | Considerar suavizar la sección 2 ("cried many tears in the dark nights"). Etiqueta `theme: ['bullying', 'sadness']`. Padre puede optar por ocultar. |
| Tortoise & Hare | Burla ("You are so slow!") | Baja | Aceptar. Oportunidad de diálogo sobre burla. |

**Recomendación general**: añadir un campo `content_flags: string[]` al modelo `Story` (ej: `['mild-peril', 'bullying', 'separation']`) y un control parental en `parental_settings` para bloquear cuentos con ciertos flags. Esto es **buen negocio también**: las familias sensibles a estos temas son un segmento de pago.

### 5.2 Diversidad cultural

🚨 **Los 5 cuentos son todos de tradición europea** (Grimm, folktale europeo, Southey inglés, Andersen danés, Esopo griego). Para una app dirigida a niños **hispanohablantes**, esto es una oportunidad perdida:
- No hay cuentos latinoamericanos (Mafalda excede dominio público, pero hay mitos mayas, leyendas andinas, cuentos afrocaribeños).
- No hay cuentos asiáticos (los de dominio público chinos o japoneses son ricos).
- No hay cuentos africanos (Anansi, por ejemplo).

**Recomendación**: añadir al menos 2 cuentos no europeos en el primer batch post-launch:
1. *"The Camel and the Pig"* (folktale hindú) — gran potencial para vocabulario de opuestos (long/short).
2. *"Anansi and the Turtle"* (folktale africano/ashanti) — moral sobre generosidad.

Esto además enriquece el sentido de inclusión y evita el sesgo eurocéntrico.

### 5.3 Faltan cuentos para 2-3 años

🚨 El demo **no tiene ningún cuento realmente adecuado para 2-3 años**. Para esa edad, lo ideal no son cuentos narrativos sino:
- **Nursery rhymes** (Twinkle Twinkle, Wheels on the Bus, Old MacDonald, Humpty Dumpty, Itsy Bitsy Spider).
- **Canciones con acciones** (Head Shoulders Knees & Toes, If You're Happy and You Know It).
- **Libros de conceptos** (colors, numbers, animals) con un objeto por página y una palabra.
- **Pattern books** (Brown Bear, Brown Bear — aunque es copyright, hay equivalentes de dominio público).

La estructura de la app (audio sync + ilustración + vocabulario) **es perfecta** para nursery rhymes; solo falta el contenido. Sugiero agregar **10 nursery rhymes** de dominio público antes del launch o en los primeros 3 meses.

---

## 6. Vocabulario y traducción

### 6.1 Selección de palabras destacadas — evaluación global

Total de palabras destacadas en los 5 cuentos: **14 palabras** (4+3+2+2+3). Esto es **insuficiente** (~3 por cuento en promedio; debiera ser 5-8 para cuentos de esa longitud).

| Palabra | Cuento | Frecuencia en inglés (COCA) | Utilidad para niño 4-7 | Veredicto |
|---------|--------|------------------------------|------------------------|-----------|
| forest | LRRH | Alta | Media | ✅ Mantener |
| wolf | LRRH, TLP | Alta | Alta | ✅ Excelente (recurrente) |
| grandmother | LRRH | Media | Media | ⚠️ Considerar *grandma* |
| basket | LRRH | Baja | Baja | ❌ Reemplazar por *mother* o *red* |
| straw | TLP | Baja | Baja | ⚠️ Defendible por contexto |
| brick | TLP | Baja-media | Media | ✅ Mantener |
| porridge | Goldilocks | Muy baja | Muy baja | ❌ Reemplazar por *soup* o eliminar |
| bears | Goldilocks | Alta | Alta (singular) | ⚠️ Cambiar a *bear* |
| duckling | Ugly Duckling | Media | Media | ✅ Mantener |
| swan | Ugly Duckling | Baja | Media | ✅ Mantener |
| tortoise | T&H | Baja | Media | ⚠️ Considerar *turtle* |
| hare | T&H | Muy baja | Baja | ❌ Considerar *rabbit* |
| race | T&H | Alta | Alta | ✅ Mantener |

**Recomendación**: aplicar **criterio de frecuencia y transferibilidad** (Nation, 2001) a toda nueva ingesta de vocabulario. Para principiantes (Tier 1), priorizar las 1.000 palabras más frecuentes del inglés general service list (West, 1953) o equivalentes modernos (NGSL, 2013).

### 6.2 Calidad de las traducciones

En general **buena**, con issues puntuales:

| Error | Cuento | Corrección |
|-------|--------|------------|
| "eclosionaron" | Ugly Duckling | "se abrieron los huevos" / "nacieros" |
| "rió y rió" | T&H | "se rió y se rió" |
| "canasta" | LRRH | Aceptable LatAm; añadir "cesta" como variante |
| "gachas" | Goldilocks | Baja frecuencia LatAm; "papilla" / "avena" |
| "salvó el día" | LRRH | Calco; "los salvó" |

**Recomendación**: aplicar **regionalización es-419** (español latinoamericano neutro) en lugar de español de España. Verificar con lector nativo (no catalán-español como yo, sino hispanoamericano) para LatAm.

### 6.3 Pronunciación IPA

El campo `phonetic` se incluye con IPA, lo cual es bueno **para profesores**. Para los padres no-bilingües (la mayoría del mercado objetivo), el IPA es **incomprensible**.

**Recomendaciones**:
1. **Ocultar IPA por defecto** en la UI; mostrar solo en "Modo padre/experto".
2. Para padres no-bilingües, añadir **pronunciación aproximada en español**: ej. *wolf → "güolf"*, *forest → "fórest"*, *basket → "básket"*. Es feo pero útil.
3. **Botón de audio 🔊 siempre presente** en el popup (ver 4.2).
4. Estandarizar IPA a **US English** (audiencia LatAm) en lugar de mezclar UK/US.

---

## 7. Mejores prácticas (Krashen, Cummins, etc.)

### 7.1 Krashen's Input Hypothesis (i+1)

**Concepto**: el input debe ser ligeramente superior al nivel actual del aprendiz (`i + 1`). Si es muy superior, es ruido; si es igual o inferior, no hay progreso.

**Evaluación de la app**:
- Para **6-7 años hispanohablantes principiantes**: los cuentos actuales son aproximadamente `i + 3 a i + 5`. Hay mucho vocabulario desconocido (*huffed, puffed, porridge, swan, steady, hatched*) en una sola sesión. **No se respeta i+1**.
- Para **2-3 años**: el input es `i + 10` (no hay `i` previo). Inapropiado.
- Para **4-5 años**: el input es `i + 2 a i + 4`. Marginalmente alto.

**Recomendación**: para respetar i+1, los cuentos deben:
- Tener **al menos 70% de vocabulario conocido** (los 100 Tier-1 más frecuentes) y solo 30% nuevo.
- Repetir **patrones sintácticos** conocidos (estructura paralela como en Goldilocks).
- Densidad léxica baja (ratio type-token alto).

Los cuentos actuales no están calibrados así. Sugiero **re-escribir los 5 cuentos** con un léxico controlado de ~150 palabras Tier-1, garantizando que cada palabra nueva aparezca con 3+ apoyos contextuales (ilustración + traducción + repetición en el texto).

### 7.2 Cummins: BICS vs CALP

**Concepto**:
- **BICS** (Basic Interpersonal Communicative Skills): lenguaje conversacional, contextualizado. Se adquiere en 1-2 años.
- **CALP** (Cognitive Academic Language Proficiency): lenguaje académico, descontextualizado. Toma 5-7 años.

**Evaluación**: la app trabaja principalmente **BICS** (cuentos narrativos con contexto), lo cual es correcto para la edad. Pero:
- Las **preguntas de comprensión** introducen algo de CALP ("Why couldn't the wolf blow down the brick house?") — inadecuado para 4-5.
- Las **explicaciones** tras error son algo formales: *"Bricks are heavy and strong. The wolf could not blow them down"* — registro académico. Para 4-5, mejor: *"The brick house was too strong! The wolf could not blow it down."*

**Recomendación**: Para 4-5 años, 100% BICS, preguntas en español, lenguaje de explicación simple y oral. Para 6-7 años, gradualmente introducir CALP.

### 7.3 Vygotsky: Zona de Desarrollo Próximo (ZDP)

**Concepto**: el aprendizaje óptimo ocurre en la brecha entre lo que el niño puede hacer solo y lo que puede hacer con ayuda.

**Evaluación**: el `VocabularyPopup` es un buen andamio (ZDP). Pero falta:
- **Andamiaje en la pregunta de comprensión**: si el niño erra, no hay pista progresiva ("Mirá la ilustración de la página 2").
- **Andamiaje entre cuentos**: no hay "cuento puente" que conecte vocabulario de un cuento anterior con uno nuevo.

### 7.4 Repetición entre cuentos

✅ *wolf* aparece en LRRH y TLP (bien).
🚨 Pero *basket*, *straw*, *brick*, *porridge*, *duckling*, *swan*, *tortoise*, *hare* aparecen una sola vez. El niño las verá **una vez en su vida** con la app actual.

**Recomendación**: diseñar una matriz léxica planificada que garantice cada palabra nueva aparezca en al menos 3 cuentos.

### 7.5 Contexto visual (ilustraciones)

🚨 En el demo, las ilustraciones son emojis (👧🐺🐻🦆🐢). Esto es **críticamente insuficiente**:
- La investigación (Carney & Levin, 2002) muestra que las ilustraciones incrementan la comprensión lectora en un **40-60%** en pre-lectores.
- En L2, las ilustraciones son **el principal sostén del input comprensible** cuando no hay L1 compartida (Mayer, 2009).
- Un emoji no permite discriminar "lobo grande y feroz" de "lobo simpático".

**Recomendación CRÍTICA**: antes del launch, **encargar o licenciar ilustraciones reales** para cada sección de cada cuento (15 ilustraciones para los 5 cuentos del demo). Recomendación de estilo: **flat design colorido** (consistente con el resto de la app) pero **escénico** (mostrar al personaje + acción + contexto).

### 7.6 Calidad del TTS para input infantil

No tengo acceso al audio TTS real (en el demo se simula con timestamps artificiales), pero la arquitectura declara uso de **Google TTS Neural2** (`en-US-Neural2-F`), que es de alta calidad. Consideraciones:
- ✅ Las voces Neural2 son indistinguibles de humanos para frases simples.
- ⚠️ Para cuentos infantiles, considerar **voces específicas de niño o de narrador con entonación expresiva**. Google TTS ofrece voces como `en-US-Neural2-F` (femenina adulta), pero la narración de cuentos infantiles suele beneficiarse de entonación más teatral. AWS Polly tiene voces como "Joanna" optimizadas para storytelling; vale la pena evaluar.
- ⚠️ Pronunciación de nombres propios: "Goldilocks", "Riding Hood" deben pronunciarse como palabras compuestas, no analizadas. SSML permite forzar pronunciación. Verificar que la ingesta con Gemini + TTS lo maneje.

---

## 8. Recomendaciones específicas

### Prioridad CRÍTICA (antes de launch — 2-4 semanas de trabajo)

1. **Corregir todos los errores gramaticales en el inglés de los 5 cuentos**. Especialmente posesivos en LRRH, TLP, Goldilocks. Es inaceptable enseñar inglés con errores. **Esfuerzo**: 2 horas de edición de `demo_data.dart`. Ver anexo A para el listado completo.
2. **Eliminar `minAge: 2` del cuento Tortoise & Hare** (cambiar a `minAge: 4`). Establecer `minAge` mínimo global de 3 años. Re-evaluar la recomendación de no ofrecer la app a menores de 3.
3. **Implementar el botón 🔊 de audio en `VocabularyPopup`**. Sin esto, el popup pierde valor pedagógico. Llamar a Google TTS en la palabra (puede pre-generarse en la ingesta como MP3s cortos por palabra, ya cachedos en Storage).
4. **Corregir el feedback de la pregunta de comprensión** en `story_end_screen.dart`:
   - Reemplazar `Colors.red` / `Icons.cancel` por color neutro + ícono de "otra oportunidad" (ej. `Icons.refresh` en color ámbar).
   - Implementar **2 reintentos** antes de mostrar la respuesta correcta.
   - Texto: "¡Casi! Sigamos intentando" en lugar de mostrar inmediatamente la explicación como error.
5. **Hacer que `words_learned` sea una métrica real**, no `storiesCompleted * 8`. Mientras tanto, **desactivar el logro `words_50`** y renombrar el campo a `words_seen` (palabras vistas) en lugar de "aprendidas". La honestidad con los padres es innegociable.
6. **Re-localizar las preguntas de comprensión según edad del niño**:
   - 4-5 años: pregunta en español, opciones en inglés.
   - 6-7 años: pregunta en inglés, opciones en inglés.
   - Implementar vía flag en `ChildProfile` o en el `ComprehensionQuestion` (campo `question_text_es`).
7. **Generar 2 preguntas más por cuento** (total 3) usando la pipeline de Gemini ya diseñada. Distribuir: 1 literal, 1 inferencial, 1 de vocabulario.
8. **Encargar 15 ilustraciones reales** (3 por cuento × 5 cuentos). Mientras tanto, documentar que el demo usa placeholders.
9. **Eliminar el selector de velocidad 1.5x** y reemplazar por [0.75x, 1.0x, 1.25x].

### Prioridad ALTA (en los primeros 3 meses post-launch)

1. **Deshabilitar los logros `streak_*` para niños con `age < 6`**. Para 6-7, mantener pero cambiar a "Leíste esta semana" (no consecutivos).
2. **Implementar `user_vocab_progress` y un SRS simple (Leitner)**. Ver sección 3.2.
3. **Agregar 5-10 nursery rhymes** para 3-4 años. Ver anexo B para listado.
4. **Agregar 2 cuentos no europeos** (Uno hindú, uno africano). Ver sección 5.2.
5. **Mostrar traducción `on by default` para niños 4-5 años**; `off by default` para 6-7.
6. **Implementar modo "Listen Only"** para 4-5 años (sin texto visible, solo ilustración + audio).
7. **Ocultar IPA por defecto** en `VocabularyPopup`; mostrar en "Modo padre". Añadir pronunciación aproximada en español para padres no-bilingües.
8. **Agregar `content_flags` al modelo `Story`** y controles parentales en `parental_settings.blocked_content_flags`.
9. **Suavizar el Ugly Duckling** sección 2 (reemplazar "cried many tears in the dark nights" por "felt sad and alone").
10. **Estandarizar IPA a US English** para audiencia LatAm.

### Prioridad MEDIA (Fase 2 — 3-6 meses post-launch)

1. **Implementar producción**: botón 🎤 en `VocabularyPopup` para grabar al niño diciendo la palabra, con speech recognition simple para feedback de pronunciación.
2. **Matriz léxica planificada**: las 100 Tier-1 palabras distribuidas en cuentos para garantizar 3+ encuentros cada una.
3. **Modo co-uso parental**: para 2-3 años, prompts en pantalla para el padre ("Pregúntale a tu hijo qué animal es este").
4. **Dashboard parental expandido**: tiempo real de aprendizaje (no de uso), palabras en SRS por nivel, recomendaciones de cuentos según gaps léxicos.
5. **Audiolibros en español premium** para cuentos clave (utiliza `audioUrlEs` ya previsto en el modelo).
6. **Detección de comprensión durante la lectura** (micro-checks opcionales entre secciones, no intrusivos).
7. **Sistema de "favoritos"** para que el niño marque cuentos favoritos (clave para 4-5 años que necesitan re-lectura).
8. **Logros de proceso**: `re_read_3_times` (re-leyó un cuento 3 veces), `vocab_explorer` (tocó 20 palabras para ver popup), `careful_listener` (escuchó a 0.75x un cuento completo).

---

## 9. Riesgos pedagógicos

### 9.1 Gamificación en edad temprana

El sistema de logros + rachas + XP puede ser **contraproducente** a esta edad por tres motivos:

1. **Motivación extrínseca desplaza a intrínseca** (efecto de sobrejustificación, Lepper et al., 1973). Si el niño lee cuentos "para ganar la insignia", deja de leerlos por placer. La investigación en lectura infantil (Gambrell, 1996) muestra que los niños motivados intrínsecamente leen 3x más y comprenden mejor.
2. **Ansiedad de pérdida** (rachas rotas) en niños que no controlan su agenda. Genera frustración injusta.
3. **Sobre-estimulación dopaminérgica** similar a la de los videojuegos, con riesgo de condicionar la atención del niño a "necesitar" la recompensa digital para sostener la tarea.

**Recomendación**: limitar la gamificación a **logros de hito discretos** (no rachas), celebraciones sobrias (sin Lottie ruidosas), y nunca penalizar la inactividad. El documento `10-accessibility.md` ya contempla un "modo simplificado" — este debe estar ON by default para 4-5 años.

### 9.2 Pantalla vs. adquisición lingüística

La investigación sobre screen time y lenguaje (Madigan et al., 2019, meta-análisis JAMA Pediatrics) muestra correlación negativa entre screen time pasivo y desarrollo del lenguaje en menores de 5 años. Sin embargo, **contenido interactivo co-usado con un adulto** no muestra este efecto (Roseberry et al., 2014). Implicaciones para StoryEnglish Kids:

- La app **debe promover activamente el co-uso parental**, no ser de "dejar al niño con la tablet".
- Para 2-3 años, agregar **pantalla inicial "Modo Padre"** que recuerde: "Para que tu hijo aproveche esta experiencia, siéntate con él/ella y comenten lo que ven".
- Para 4-5 años, prompts intermitentes: "¡Mostrale a mamá/papá qué animal viste!".
- Evitar sesiones largas: prompt de "tomemos un descanso" cada 15 minutos (en lugar de los 60 min del logro `time_60_min`).

### 9.3 Pregunta de comprensión y ansiedad

Ya tratado en 4.3. La pregunta al final, tal como está implementada (en inglés, sin retry, con feedback rojo), **puede generar aversión a la app**. Un niño de 4 años que no entiende la pregunta y recibe feedback rojo está siendo evaluado injustamente. Esto viola el principio de **no daño** que debe regir toda intervención educativa temprana.

### 9.4 Expectativas parentales descalibradas

🚨 Este es el riesgo **más subestimado**. Si la app dice a los padres "tu hijo aprendió 50 palabras" (basado en la métrica falsa actual), los padres pueden:
- Reducir otras formas de exposición al inglés (canciones, juegos presenciales).
- Esperar del niño una producción que no va a ocurrir (porque input sin output no genera producción fluida).
- Presionar al niño a usar la app más de lo saludable.

**Recomendación**: en el dashboard parental, usar lenguaje honesto: "Tu hijo vio 50 palabras en inglés, de las cuales reconoció correctamente N en los ejercicios". Nunca afirmar "aprendió X palabras" sin medición real.

### 9.5 Riesgo de input defectuoso

Ya destacado: los errores gramaticales en el inglés fuente (posesivos omitidos) son **el riesgo más severo y más fácil de corregir**. Un niño que internalice *"my grandmother house"* como patrón correcto va a requerir **desaprendizaje** posterior, que es cognitivamente costoso. Es más grave que no aprender nada.

---

## 10. Veredicto final

### 🟡 LANZAR CON CONDICIONES

La app **no debe publicarse en su estado actual**, pero los cambios críticos son acotados y alcanzables en **3-4 semanas de trabajo** del equipo actual. La base técnica (arquitectura, modelo de datos, UI) es buena y no requiere rediseño; lo que requiere es **rigor pedagógico en el contenido y diferenciación por edad**.

### Cambios críticos bloqueantes (deben cumplirse antes de cualquier launch):

1. ✅ Corregir **todos los errores gramaticales** en el inglés de los 5 cuentos (posesivos en LRRH, TLP, Goldilocks).
2. ✅ Implementar **botón de audio 🔊 en `VocabularyPopup`**.
3. ✅ Corregir el **feedback de la pregunta de comprensión** (sin rojo, con retry, mensaje motivador).
4. ✅ **Localizar la pregunta según edad** (español para 4-5, inglés para 6-7).
5. ✅ **Eliminar o renombrar la métrica `words_learned`** (no afirmar aprendizaje no medido).
6. ✅ **Cambiar `minAge: 2` a `minAge: 4` en Tortoise & Hare** y revisar todas las edades mínimas.
7. ✅ **Eliminar velocidad 1.5x** del selector de audio.
8. ✅ **Encargar o licenciar ilustraciones reales** (al menos placeholders de mejor calidad que emojis para el launch público).
9. ✅ **Deshabilitar logros `streak_*` para age < 6**.
10. ✅ **Corregir traducciones** ("eclosionaron", "rió y rió").

### Justificación

StoryEnglish Kids tiene el potencial de ser una app genuinamente útil para familias hispanohablantes. La feature central (audio sincronizado + texto resaltado) es **pedagógicamente correcta y bien implementada**. El modelo de datos contempla los componentes necesarios. La accesibilidad está pensada con seriedad. Lo que falla es **el contenido real** del demo: errores gramaticales, métricas falsas, preguntas inadecuadas por edad, vocabulario subóptimo, ilustraciones insuficientes, ausencia de retrials.

Estos problemas son **corregibles sin rediseñar la app**. Con 3-4 semanas de trabajo enfocado (contenido + UX de feedback + ilustraciones), StoryEnglish Kids puede pasar de 🟡 a 🟢 y ser una herramienta valiosa.

Sin estos cambios, **no recomiendo el lanzamiento**: el riesgo de dañar la confianza de los padres (que verán a sus hijos recibir feedback rojo sin entender por qué, "aprender" gramática defectuosa, y "ganar" insignias por logros no medidos) es alto y va a comprometer la reputación del producto.

Estoy disponible para trabajar con el equipo en la implementación de los cambios si lo desean.

---

## Anexo A: Listado de correcciones gramaticales y de traducción

### A.1 Errores gramaticales en inglés (CRÍTICO — corregir antes de launch)

**Little Red Riding Hood** (sección 2):
- ❌ `"I am going to my grandmother house," she said.`
- ✅ `"I am going to my grandmother's house," she said.`

**Three Little Pigs** (sección 2):
- ❌ `"The first pig ran to his brother wood house."`
- ✅ `"The first pig ran to his brother's wood house."`

**Goldilocks** (sección 2) — 3 errores:
- ❌ `"Papa porridge was too hot."`
- ✅ `"Papa Bear's porridge was too hot."`
- ❌ `"Mama porridge was too cold."`
- ✅ `"Mama Bear's porridge was too cold."`
- ❌ `"Baby porridge was just right, and she ate it all!"`
- ✅ `"Baby Bear's porridge was just right, and she ate it all!"`

**Goldilocks** (sección 3) — 2 errores:
- ❌ `"Goldilocks sat in the bears chairs and broke the baby chair."`
- ✅ `"Goldilocks sat in the bears' chairs and broke Baby Bear's chair."`
- ❌ `"Then she slept in the baby bed."`
- ✅ `"Then she slept in Baby Bear's bed."`

### A.2 Errores de traducción

**Ugly Duckling** (sección 1):
- ❌ `"Un día, ¡eclosionaron!"`
- ✅ `"Un día, ¡los huevos se abrieron!"`

**Tortoise & Hare** (sección 1):
- ❌ `"La liebre rió y rió."`
- ✅ `"La liebre se rió y se rió."`

---

## Anexo B: Cuentos y nursery rhymes recomendados para agregar

### B.1 Nursery rhymes para 3-4 años (10 sugerencias)

Todas de dominio público, perfectas para el modelo de audio sync:

1. **Twinkle, Twinkle, Little Star** — vocabulario: star, sky, world, light, diamond.
2. **The Wheels on the Bus** — vocabulario: wheels, bus, door, wipers, horn, driver.
3. **Old MacDonald Had a Farm** — vocabulario: cow, pig, duck, sheep, chicken + onomatopeyas.
4. **Itsy Bitsy Spider** — vocabulario: spider, water spout, rain, sun.
5. **Humpty Dumpty** — vocabulario: wall, fall, horses, men.
6. **Head, Shoulders, Knees and Toes** — vocabulario: partes del cuerpo (clave para ESL temprano).
7. **If You're Happy and You Know It** — vocabulario: emociones + acciones (clap, stomp, nod).
8. **Row, Row, Row Your Boat** — vocabulario: boat, river, stream.
9. **Baa Baa Black Sheep** — vocabulario: sheep, wool, master, dame, boy.
10. **Five Little Monkeys** — vocabulario: monkeys, bed, jump, bump, doctor.

### B.2 Cuentos para 4-5 años (5 sugerencias, dominio público)

1. **The Lion and the Mouse** (Aesop) — moraleja sobre generosidad. Vocabulario: lion, mouse, net, help.
2. **The Boy Who Cried Wolf** (Aesop) — honestidad. Vocabulario: boy, sheep, wolf, lie, true.
3. **The Camel and the Pig** (folktale hindú) — auto-aceptación. Vocabulario: camel, pig, short, tall.
4. **Anansi and the Turtle** (folktale ashanti) — generosidad. Vocabulario: spider, turtle, dinner, share.
5. **The Greedy Dog** (folktale universal) — avaricia. Vocabulario: dog, bone, river, reflection.

### B.3 Cuentos para 6-7 años (3 sugerencias, dominio público)

1. **The Selfish Giant** (Oscar Wilde, dominio público en algunas jurisdicciones) — sacrificio y amistad. Verificar estatus legal.
2. **The Happy Prince** (Oscar Wilde) — compasión. Verificar estatus legal.
3. **The Wind and the Sun** (Aesop) — persuasión vs fuerza. Vocabulario: wind, sun, warm, cold, coat.

---

## Anexo C: Vocabulario sugerido por edad (Tier 1)

Basado en New General Service List (2013) y listas de vocabulario ESL infantil (Milton, 2009).

### C.1 Para 3-4 años (30 palabras clave)

**Familia**: mother, father, baby, brother, sister, grandma, grandpa
**Animales**: dog, cat, bird, fish, cow, duck, pig, horse
**Cuerpo**: head, hand, foot, eye, ear, nose, mouth
**Comida**: milk, water, apple, bread, egg
**Colores**: red, blue, yellow, green
**Acciones**: eat, sleep, run, walk, see, hear

### C.2 Para 5-6 años (50 palabras adicionales)

**Familia extendida**: family, aunt, uncle, cousin
**Animales más**: rabbit, mouse, lion, bear, monkey, elephant, chicken, frog
**Cuerpo más**: finger, toe, tooth, hair
**Comida más**: rice, meat, soup, fruit, cookie
**Colores más**: orange, purple, pink, brown, black, white
**Números 1-10**: one, two, three, four, five, six, seven, eight, nine, ten
**Adjetivos**: big, small, hot, cold, happy, sad, fast, slow, good, bad
**Acciones más**: jump, swim, fly, sing, dance, play, read, write, draw, drink

### C.3 Para 6-7 años (40 palabras adicionales)

**Tiempo**: day, night, morning, sun, moon, star, today, tomorrow
**Lugares**: house, school, park, store, city, farm, forest, river
**Objetos**: book, chair, table, bed, door, window, car, bike
**Adjetivos más**: long, short, tall, hard, soft, clean, dirty, open, closed
**Verbos cognitivos**: think, know, want, like, love, remember
**Conectores**: and, but, because, then, so, when, where, why, what, who

---

## Anexo D: Referencias académicas

- Bjork, R. A. (1994). Memory and metamemory considerations in the training of human beings. In J. Metcalfe & A. P. Shimamura (Eds.), *Metacognition* (pp. 185-205). MIT Press.
- Cameron, L. (2001). *Teaching Languages to Young Learners*. Cambridge University Press.
- Carney, R. N., & Levin, J. R. (2002). Pictorial illustrations still improve students' learning from text. *Educational Psychology Review*, 14(1), 5-26.
- Cepeda, N. J., Pashler, H., Vul, E., Wixted, J. T., & Rohrer, D. (2008). Distributed practice in verbal recall tasks: A review and quantitative synthesis. *Psychological Bulletin*, 132(3), 354-380.
- Cummins, J. (1979). Cognitive/academic language proficiency, linguistic interdependence, the optimum age question and some other matters. *Working Papers on Bilingualism*, No. 19, 121-129.
- Gambrell, L. B. (1996). Creating classroom cultures that foster reading motivation. *The Reading Teacher*, 50(1), 14-25.
- Korat, O., & Shamir, A. (2007). Electronic books versus adult readers: A comparison of their effects on emergent reading. *Reading and Writing*, 20(8), 825-843.
- Krashen, S. (1982). *Principles and Practice in Second Language Acquisition*. Pergamon.
- Kuhl, P. K. (2004). Early language acquisition: cracking the speech code. *Nature Reviews Neuroscience*, 5(11), 831-843.
- Lepper, M. R., Greene, D., & Nisbett, R. E. (1973). Undermining children's intrinsic interest with extrinsic reward. *Journal of Personality and Social Psychology*, 28(1), 129-137.
- Madigan, S., Browne, D., Racine, N., Mori, C., & Tough, S. (2019). Association between screen time and children's performance on a developmental screening test. *JAMA Pediatrics*, 173(3), 244-250.
- Mayer, R. E. (2009). *Multimedia Learning* (2nd ed.). Cambridge University Press.
- Nation, I. S. P. (2001). *Learning Vocabulary in Another Language*. Cambridge University Press.
- Roseberry, S., Hirsh-Pasek, K., & Golinkoff, R. M. (2014). Skype me! Socially contingent interactions help toddlers learn language. *Child Development*, 85(3), 956-970.
- Schmitt, N. (2010). *Researching Vocabulary: A Vocabulary Research Manual*. Palgrave Macmillan.
- Swain, M. (1985). Communicative competence: some roles of comprehensible input and comprehensible output in its development. In S. Gass & C. Madden (Eds.), *Input in Second Language Acquisition* (pp. 235-253). Newbury House.
- Vygotsky, L. S. (1978). *Mind in Society: The Development of Higher Psychological Processes*. Harvard University Press.
- Weisleder, A., & Fernald, A. (2013). Talking to children matters: early language experience strengthens processing and builds vocabulary. *Psychological Science*, 24(11), 2143-2152.
- West, M. (1953). *A General Service List of English Words*. Longman.

---

*Fin del informe. Quedo a disposición del equipo para clarificaciones o para acompañar la implementación de los cambios.*

**Dra. María Fernández**
María Fernández, PhD
Especialista en Enseñanza de Inglés para Niños (1-7 años)
Junio 2026
