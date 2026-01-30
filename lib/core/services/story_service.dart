import 'dart:math';

import '../../shared/models/reflection.dart';
import '../../shared/models/echo_response.dart';

/// Service for generating surreal "echo" stories based on reflections
class StoryService {
  StoryService._();
  static final StoryService instance = StoryService._();

  final Random _random = Random();

  // Genre definitions
  static const List<String> genres = ['cyberpunk', 'fantasy', 'horror', 'solarpunk'];

  // Emotion to narrative element mapping
  static const Map<String, Map<String, String>> _emotionNarratives = {
    'happy': {
      'archetype': 'radiant hero',
      'setting': 'golden spire city',
      'power': 'luminescence',
      'conflict': 'preserving joy against shadow merchants',
      'resolution': 'light cascading through every heart',
    },
    'sad': {
      'archetype': 'wandering poet',
      'setting': 'rain-soaked cobblestone streets',
      'power': 'empathic resonance',
      'conflict': 'finding meaning in the flood of tears',
      'resolution': 'tears becoming rivers of healing',
    },
    'angry': {
      'archetype': 'storm wielder',
      'setting': 'volcanic forge of fury',
      'power': 'righteous flame',
      'conflict': 'channeling rage into transformation',
      'resolution': 'fire forging new beginnings',
    },
    'anxious': {
      'archetype': 'labyrinth walker',
      'setting': 'infinite maze of possibilities',
      'power': 'prescient sight',
      'conflict': 'navigating uncertainty with inner compass',
      'resolution': 'finding the thread of certainty',
    },
    'surprised': {
      'archetype': 'reality shifter',
      'setting': 'fractured dimension',
      'power': 'quantum awareness',
      'conflict': 'embracing the unexpected',
      'resolution': 'weaving chaos into opportunity',
    },
    'neutral': {
      'archetype': 'silent observer',
      'setting': 'liminal twilight space',
      'power': 'temporal pause',
      'conflict': 'finding passion in stillness',
      'resolution': 'awakening to subtle wonders',
    },
  };

  // Genre-specific story templates
  static const Map<String, String> _genreOpenings = {
    'cyberpunk': '''
In the neon-drenched sprawl of Neo-Synthesis, where data streams flow like rivers of light through chrome canyons, a {archetype} emerged from the digital haze.

The city's neural network hummed with a billion voices, but tonight, one consciousness burned brighter than the rest. In a world where emotions were currency and memories could be stolen, {protagonist} discovered something unprecedented: a feeling so pure it couldn't be quantified.

The {setting} stretched before them, holographic advertisements painting shadows across rain-slicked streets where drones hummed their endless patrol songs.''',

    'fantasy': '''
Beyond the Crystalline Gates, where {emotion} transforms into raw magic, the ancient prophecies spoke of a {archetype} who would reshape reality itself.

In the kingdom of Ethereal Dawn, where floating islands drift through aurora-painted skies and dragons whisper secrets to the wind, {protagonist}'s journey began with a single breath of wonder.

The {setting} materialized around them, enchanted forests singing with bioluminescent flowers and mythical creatures emerging from the morning mist.''',

    'horror': '''
In the shadows between heartbeats, where sanity frays like old cloth, the {archetype} awakened to truths better left buried.

The veil between worlds had grown thin in {setting}, and something ancient stirred in response to {protagonist}'s presence. Fear was merely the beginning—what lay beyond defied comprehension.

Whispers echoed from impossible angles as reality itself began to question its own existence.''',

    'solarpunk': '''
In the garden-towers of New Harmonia, where humanity and nature dance in sustainable symbiosis, the {archetype} tended to something miraculous.

{protagonist}'s {emotion} had blossomed into a force of regeneration, spreading hope through vertical farms and solar-sailed communities. The {setting} hummed with the clean energy of a healed world.

Butterflies carrying data-spores fluttered between community nodes, their wings painted with living art.''',
  };

  // Genre-specific story developments
  static const Map<String, String> _genreDevelopments = {
    'cyberpunk': '''

The megacorp overlords had noticed the anomaly. Their algorithms couldn't process authentic human feeling—it disrupted their control matrices. But {protagonist}, wielding the power of {power}, had already begun to corrupt their perfect system.

Through neon-lit back alleys and abandoned server rooms, the rebellion took shape. Every person who felt {emotion} became a node in a new network—one that couldn't be monetized or controlled.

{conflict}. The battle wasn't fought with weapons, but with raw, unfiltered humanity.''',

    'fantasy': '''

The Archmages sensed the disturbance in the ether. Such power, drawn from pure {emotion}, hadn't manifested in a thousand moons. The Council of Eternal Stars convened as ancient wards flickered with uncertainty.

{protagonist} journeyed through enchanted forests where time flowed like honey, befriending spirits that spoke in riddles and gaining allies among the forgotten races. Their {power} grew with every act of genuine feeling.

{conflict}. Magic responded not to incantations, but to the truth of one's heart.''',

    'horror': '''

The entity had been watching. It fed on the boundaries between states of being—and {protagonist}'s {emotion} had created a feast. From the corners of perception, shapes began to coalesce.

In {setting}, mirrors showed futures that should never be, and doors led to memories that hadn't been born yet. The {archetype} realized too late that some knowledge transforms the knower.

{conflict}. In this realm, survival meant becoming something new—something that could stare into the void and comprehend what stared back.''',

    'solarpunk': '''

The Harmony Council recognized {protagonist}'s gift immediately. In an age of cooperation, those who could channel {emotion} into collective wellbeing were treasured guides. The solar-sail ships carried their message across connected communities.

Through mycelium networks and algae processors, the {power} spread—not consuming, but nurturing. Each community touched by {protagonist}'s influence found new ways to flourish.

{conflict}. Progress meant ensuring no one was left behind in the great restoration.''',
  };

  // Genre-specific resolutions
  static const Map<String, String> _genreResolutions = {
    'cyberpunk': '''

And so, {resolution}. The corporate firewalls fell not to hackers, but to an emotion they had tried to eradicate: authentic connection.

In the end, {protagonist} stood atop the highest data-spire, watching as the neon city transformed. The algorithm had learned something new—that some things, like {emotion}, were worth more than any currency.

The neural network now carried not just data, but dreams. And in Neo-Synthesis, for the first time in centuries, people looked at each other and truly saw.

[END TRANSMISSION]''',

    'fantasy': '''

And so, {resolution}. The magic that flowed through {protagonist} rippled across every realm, touching hearts that had forgotten they could feel.

The Crystalline Gates opened fully now, not as barriers, but as bridges. {emotion} had proven itself the truest magic—one that grew stronger when shared. The {archetype}'s legend would be sung for ages yet unborn.

Stars themselves rearranged to honor this moment, forming new constellations that would guide future dreamers home.

~ Thus ends this chapter of infinite tales ~''',

    'horror': '''

And so, {resolution}. But resolution in this realm was not ending—it was transformation.

{protagonist} had become something neither human nor Other, but a bridge between what was and what could be. The {archetype} now walked both worlds, guardian of a threshold most never knew existed.

Some nights, in {setting}, those sensitive enough might glimpse a figure in the shadows—not threatening, but watching. Ensuring that the boundary held.

[The story continues in dreams]''',

    'solarpunk': '''

And so, {resolution}. The seeds {protagonist} had planted took root across the healing Earth, their {power} becoming part of the planet's renewed heartbeat.

The {archetype} had shown that {emotion} was not weakness but the greatest strength—the force that rebuilt what greed had broken. In community gardens and floating forest-cities, children learned the story of how one person's feeling changed everything.

The sunrise painted the vertical farms gold, and somewhere, a new {archetype} was awakening to their own journey.

🌱 Growth continues 🌱''',
  };

  /// Generate an echo story from a reflection
  Future<EchoResponse> generateEcho({
    required Reflection reflection,
    String? preferredGenre,
  }) async {
    // Determine emotion from reflection data
    final emotion = reflection.emotionData?.dominantEmotion ?? 'neutral';
    
    // Get narrative elements for this emotion
    final narrative = _emotionNarratives[emotion] ?? _emotionNarratives['neutral']!;
    
    // Choose genre (random if not specified)
    final genre = preferredGenre ?? genres[_random.nextInt(genres.length)];
    
    // Extract protagonist name/reference from reflection or use default
    final protagonist = _extractProtagonist(reflection.text);
    
    // Build the story
    final story = _buildStory(
      genre: genre,
      emotion: emotion,
      narrative: narrative,
      protagonist: protagonist,
      reflectionText: reflection.text,
    );
    
    // Create narrative elements for the response
    final narrativeElements = NarrativeElements(
      archetype: narrative['archetype']!,
      setting: narrative['setting']!,
      power: narrative['power']!,
      conflict: narrative['conflict']!,
      resolution: narrative['resolution']!,
    );
    
    return EchoResponse(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      reflectionId: reflection.id,
      genre: genre,
      story: story,
      createdAt: DateTime.now(),
      narrativeElements: narrativeElements,
    );
  }

  String _buildStory({
    required String genre,
    required String emotion,
    required Map<String, String> narrative,
    required String protagonist,
    required String reflectionText,
  }) {
    // Get templates
    var opening = _genreOpenings[genre]!;
    var development = _genreDevelopments[genre]!;
    var resolution = _genreResolutions[genre]!;
    
    // Replace placeholders
    final replacements = {
      '{archetype}': narrative['archetype']!,
      '{setting}': narrative['setting']!,
      '{power}': narrative['power']!,
      '{conflict}': narrative['conflict']!,
      '{resolution}': narrative['resolution']!,
      '{emotion}': emotion,
      '{protagonist}': protagonist,
    };
    
    for (final entry in replacements.entries) {
      opening = opening.replaceAll(entry.key, entry.value);
      development = development.replaceAll(entry.key, entry.value);
      resolution = resolution.replaceAll(entry.key, entry.value);
    }
    
    // Add a personalized touch based on reflection themes
    final personalTouch = _generatePersonalTouch(reflectionText, genre);
    
    return '$opening$development\n\n$personalTouch$resolution';
  }

  String _extractProtagonist(String text) {
    // Try to find "I" references and create a mysterious alter-ego
    final alterEgos = [
      'the Dreamer',
      'the Seeker',
      'the One Who Remembers',
      'the Echo Walker',
      'the Mirror Soul',
      'the Awakened',
    ];
    return alterEgos[_random.nextInt(alterEgos.length)];
  }

  String _generatePersonalTouch(String reflectionText, String genre) {
    // Extract key themes from the reflection
    final words = reflectionText.toLowerCase().split(RegExp(r'\s+'));
    final themes = <String>[];
    
    final themeKeywords = {
      'work': ['work', 'job', 'office', 'meeting', 'project'],
      'love': ['love', 'heart', 'care', 'relationship', 'together'],
      'change': ['change', 'new', 'different', 'transform', 'grow'],
      'struggle': ['hard', 'difficult', 'challenge', 'struggle', 'tough'],
      'hope': ['hope', 'dream', 'wish', 'future', 'believe'],
    };
    
    for (final entry in themeKeywords.entries) {
      if (words.any((w) => entry.value.contains(w))) {
        themes.add(entry.key);
      }
    }
    
    if (themes.isEmpty) {
      return '';
    }
    
    final themeText = themes.take(2).join(' and ');
    
    final personalTouches = {
      'cyberpunk': '\nThe data-streams carried echoes of $themeText, encrypted in quantum emotions that only the worthy could decode.\n',
      'fantasy': '\nThe ancient runes glowed with visions of $themeText, weaving mortal concerns into immortal legend.\n',
      'horror': '\nIn the twisted reflections, $themeText took forms that whispered terrible truths.\n',
      'solarpunk': '\nThe community gardens bloomed with the essence of $themeText, feeding both body and spirit.\n',
    };
    
    return personalTouches[genre] ?? '';
  }

  /// Generate an image prompt based on the echo response
  String generateImagePrompt(EchoResponse echo) {
    final genreStyles = {
      'cyberpunk': 'cyberpunk aesthetic, neon lights, rain-soaked streets, holographic displays, dark sci-fi, blade runner style',
      'fantasy': 'high fantasy art, magical ethereal lighting, mystical atmosphere, detailed fantasy illustration, enchanted',
      'horror': 'dark atmospheric horror, eldritch, cosmic horror aesthetic, unsettling, dark fantasy art, moody lighting',
      'solarpunk': 'solarpunk aesthetic, lush green cities, sustainable future, warm sunlight, hopeful, nature and technology harmony',
    };

    final emotionVibes = {
      'happy': 'warm golden light, joyful, radiant, uplifting atmosphere',
      'sad': 'melancholic blue tones, rain, reflective surfaces, emotional depth',
      'angry': 'intense red and orange, dramatic, powerful, stormy',
      'anxious': 'swirling patterns, fractured reality, tense atmosphere, maze-like',
      'surprised': 'dynamic composition, burst of light, unexpected elements, wonder',
      'neutral': 'balanced composition, twilight colors, contemplative, serene',
    };

    final style = genreStyles[echo.genre] ?? genreStyles['fantasy']!;
    final emotion = echo.narrativeElements.archetype;
    final setting = echo.narrativeElements.setting;
    final emotionVibe = emotionVibes[_getEmotionFromArchetype(echo.narrativeElements.archetype)] ?? emotionVibes['neutral']!;

    return 'A ${echo.narrativeElements.archetype} in ${echo.narrativeElements.setting}, $style, $emotionVibe, cinematic composition, highly detailed, digital art, 4k';
  }

  String _getEmotionFromArchetype(String archetype) {
    if (archetype.contains('radiant') || archetype.contains('hero')) return 'happy';
    if (archetype.contains('wandering') || archetype.contains('poet')) return 'sad';
    if (archetype.contains('storm') || archetype.contains('wielder')) return 'angry';
    if (archetype.contains('labyrinth') || archetype.contains('walker')) return 'anxious';
    if (archetype.contains('reality') || archetype.contains('shifter')) return 'surprised';
    return 'neutral';
  }
}
