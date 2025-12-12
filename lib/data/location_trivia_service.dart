import 'dart:math';

import 'package:geolocator/geolocator.dart';

import 'models.dart';

class LocationTriviaService {
  final Map<int, List<_Fact>> _factBank = {
    1: [
      _Fact(
        prompt: 'The ${_highlight("Canal District")} once moved salt by which famous New York waterway?',
        options: ['Erie Canal', 'Hudson River', 'Seneca River', 'Oswego Creek'],
        answer: 0,
        category: 'Local History',
      ),
      _Fact(
        prompt: 'Clinton Square is known for converting into which seasonal attraction every winter?',
        options: ['Ski lift', 'Outdoor market', 'Ice rink', 'Concert stage'],
        answer: 2,
        category: 'Traditions',
      ),
      _Fact(
        prompt: 'Which statue stands guard over the Canal District plaza?',
        options: [
          'Christopher Columbus',
          'Jerry Rescue',
          'Erastus Palmer',
          'Onondaga Chief Hiawatha'
        ],
        answer: 1,
        category: 'Landmarks',
      ),
    ],
    2: [
      _Fact(
        prompt:
            'Marshall Street in the ${_highlight("University Commons")} caters mainly to which crowd?',
        options: ['Art collectors', 'Commuters', 'Students', 'Tour bus drivers'],
        answer: 2,
        category: 'Campus Life',
      ),
      _Fact(
        prompt: 'Which stadium looms over University Commons and hosts the Orange?',
        options: ['JMA Dome', 'Carrier Dome', 'State Fair Coliseum', 'Oncenter War Memorial'],
        answer: 0,
        category: 'Sports',
      ),
      _Fact(
        prompt: 'Grab-and-go spots on Marshall Street are famous for what late-night staple?',
        options: ['Sushi boats', 'The garbage plate', 'Colossal cookies', 'Disco fries'],
        answer: 3,
        category: 'Food Lore',
      ),
    ],
    3: [
      _Fact(
        prompt:
            'The ${_highlight("Dome Line")} glows orange on game nights to celebrate which university?',
        options: [
          'Cornell University',
          'Syracuse University',
          'SUNY ESF',
          'RIT'
        ],
        answer: 1,
        category: 'Spirit',
      ),
      _Fact(
        prompt: 'Before a 2022 rename, what was the JMA Dome called?',
        options: ['War Memorial', 'Carrier Dome', 'Great Northern Dome', 'Empire Dome'],
        answer: 1,
        category: 'History',
      ),
      _Fact(
        prompt: 'Which feature makes the dome famous among indoor arenas?',
        options: [
          'Retractable ice rink',
          'Bubble roof',
          'Glass walls',
          'Built-in hotel'
        ],
        answer: 1,
        category: 'Architecture',
      ),
    ],
    4: [
      _Fact(
        prompt:
            'Westcott Ridge is the gateway to which indie-friendly street festival each fall?',
        options: [
          'Peach Festival',
          'New York State Fair',
          'Westcott Street Cultural Fair',
          'Taste of Syracuse'
        ],
        answer: 2,
        category: 'Culture',
      ),
      _Fact(
        prompt: 'Funk ’n Waffles in Westcott is famous for pairing live music with what?',
        options: ['Espresso flights', 'Savory waffles', 'Board games', 'Arcade cabinets'],
        answer: 1,
        category: 'Food & Music',
      ),
      _Fact(
        prompt: 'Which indie theater anchors the art scene on Westcott Street?',
        options: [
          'Landmark Theatre',
          'Westcott Theater',
          'Redhouse Arts Center',
          'MOST Dome'
        ],
        answer: 1,
        category: 'Arts',
      ),
    ],
  };

  Future<List<Question>> generateQuestionsFor(
    Territory territory, {
    Position? position,
    double? distanceMeters,
  }) async {
    final facts = List<_Fact>.from(
      _factBank[territory.id] ?? _buildDynamicFacts(territory),
    );

    if (distanceMeters != null) {
      facts.add(_distanceFact(territory, distanceMeters));
    }

    return _toQuestions(facts, territory.id);
  }

  List<_Fact> _buildDynamicFacts(Territory territory) {
    final random = Random(territory.id);
    final shuffled = territory.hotCategories.toList()..shuffle(random);

    return [
      _Fact(
        prompt: '${territory.name} is anchored by which landmark?',
        options: [
          territory.landmark,
          'Armory Square',
          'Destiny USA',
          'Inner Harbor'
        ],
        answer: 0,
        category: 'Landmark',
      ),
      _Fact(
        prompt: 'Which theme best fits current hot categories?',
        options: [
          shuffled.take(2).join(' & '),
          'Sailing & aviation',
          'Botany & zoology',
          'Finance & politics'
        ],
        answer: 0,
        category: 'Culture',
      ),
      _Fact(
        prompt: 'A control radius of ${territory.radiusMeters}m feels closest to which walk time?',
        options: ['2 minutes', '5 minutes', '10 minutes', '30 minutes'],
        answer: territory.radiusMeters < 400
            ? 1
            : territory.radiusMeters < 650
                ? 2
                : 3,
        category: 'Navigation',
      ),
    ];
  }

  _Fact _distanceFact(Territory territory, double distanceMeters) {
    final kilo = distanceMeters / 1000;
    final options = _buildDistanceOptions(kilo);
    final answer = options.indexWhere(
      (element) => element.contains(_formatDistance(kilo)),
    );
    return _Fact(
      prompt: 'How far are you from ${territory.name} right now?',
      options: options,
      answer: answer == -1 ? 0 : answer,
      category: 'Your Trail',
    );
  }

  List<String> _buildDistanceOptions(double kilometers) {
    final normalized = max(0.05, kilometers);
    final bucket = _formatDistance(normalized);
    final offsets = [-0.2, 0.3, -0.5, 0.6];
    return offsets
        .map(
          (offset) => _formatDistance((normalized + offset).clamp(0.05, normalized + 2)),
        )
        .toList()
      ..[Random().nextInt(offsets.length)] = bucket;
  }

  String _formatDistance(double kilometers) {
    if (kilometers < 1) {
      return '${(kilometers * 1000).round()} m';
    }
    return '${kilometers.toStringAsFixed(2)} km';
  }

  List<Question> _toQuestions(List<_Fact> facts, int territoryId) {
    int id = territoryId * 100;
    return facts
        .map(
          (fact) => Question(
            id: id++,
            territoryId: territoryId,
            text: fact.prompt,
            options: fact.options,
            correctIndex: fact.answer,
            category: fact.category,
          ),
        )
        .toList();
  }

  static String _highlight(String text) => text.toUpperCase();
}

class _Fact {
  final String prompt;
  final List<String> options;
  final int answer;
  final String category;

  const _Fact({
    required this.prompt,
    required this.options,
    required this.answer,
    required this.category,
  });
}
