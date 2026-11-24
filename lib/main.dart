import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:lottie/lottie.dart';

// ============================================================================
// GESTOR DE EFECTOS DE SONIDO Y MÚSICA DOJO (AUDIO ENGINE)
// ============================================================================
class SoundEffects {
  static final AudioPlayer _bgmPlayer = AudioPlayer();
  static final List<AudioPlayer> _sfxPool = List.generate(6, (_) => AudioPlayer());
  static int _sfxIdx = 0;
  static bool musicEnabled = true;
  static bool sfxEnabled = true;
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    try {
      await AudioPlayer.global.setAudioContext(AudioContext(
        android: AudioContextAndroid(
          isSpeakerphoneOn: false,
          stayAwake: false,
          contentType: AndroidContentType.sonification,
          usageType: AndroidUsageType.game,
          audioFocus: AndroidAudioFocus.none,
        ),
      ));
      await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
      await _bgmPlayer.setVolume(0.38);
      for (final p in _sfxPool) {
        await p.setPlayerMode(PlayerMode.lowLatency);
        await p.setVolume(1.0);
      }
      if (musicEnabled) {
        startMusic();
      }
    } catch (_) {}
  }

  static void startMusic() {
    if (!musicEnabled) return;
    try {
      _bgmPlayer.setVolume(0.38);
      _bgmPlayer.play(AssetSource('audio/dojo_music.wav'));
    } catch (_) {}
  }

  static void stopMusic() {
    try {
      _bgmPlayer.stop();
    } catch (_) {}
  }

  static void toggleMusic() {
    musicEnabled = !musicEnabled;
    if (musicEnabled) {
      startMusic();
    } else {
      stopMusic();
    }
  }

  static void setMusicVolume(double vol) {
    if (!musicEnabled) return;
    try {
      _bgmPlayer.setVolume(vol);
    } catch (_) {}
  }

  static void playSfx(String assetPath, {double volume = 1.0}) {
    if (!sfxEnabled) return;
    try {
      final p = _sfxPool[_sfxIdx];
      _sfxIdx = (_sfxIdx + 1) % _sfxPool.length;
      p.setVolume(volume);
      p.play(AssetSource(assetPath), mode: PlayerMode.lowLatency);
    } catch (_) {}
  }

  static void playSlash() => playSfx('audio/katana_slash.wav', volume: 1.0);
  static void playSplat() => playSfx('audio/fruit_splat.wav', volume: 1.0);
  static void playBomb() => playSfx('audio/bomb_explode.wav', volume: 1.0);
  static void playCombo() => playSfx('audio/combo.wav', volume: 1.0);
}

double _hypot(double a, double b) => math.sqrt(a * a + b * b);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setPreferredOrientations(DeviceOrientation.values);
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: FruitDojoGame(),
  ));
}

// ============================================================================
// 1. ANIMACIONES LOTTIE EMBEBIDAS (Reemplazables por Lottie.asset('...'))
// ============================================================================
const String _bombLottieJson = r'''
{"v":"5.7.4","fr":60,"ip":0,"op":60,"w":140,"h":140,"nm":"BombLottie","ddd":0,"assets":[],"layers":[
{"ddd":0,"ind":1,"ty":4,"nm":"Glow","sr":1,"ao":0,"ip":0,"op":60,"st":0,"bm":0,"ks":{"o":{"a":1,"k":[{"t":0,"s":[25],"i":{"x":[0.5],"y":[0.5]},"o":{"x":[0.5],"y":[0.5]}},{"t":30,"s":[75],"i":{"x":[0.5],"y":[0.5]},"o":{"x":[0.5],"y":[0.5]}},{"t":60,"s":[25]}]},"r":{"a":0,"k":0},"p":{"a":0,"k":[70,76,0]},"a":{"a":0,"k":[0,0,0]},"s":{"a":1,"k":[{"t":0,"s":[90,90,100],"i":{"x":[0.5,0.5,0.5],"y":[0.5,0.5,0.5]},"o":{"x":[0.5,0.5,0.5],"y":[0.5,0.5,0.5]}},{"t":30,"s":[118,118,100],"i":{"x":[0.5,0.5,0.5],"y":[0.5,0.5,0.5]},"o":{"x":[0.5,0.5,0.5],"y":[0.5,0.5,0.5]}},{"t":60,"s":[90,90,100]}]}},"shapes":[{"ty":"gr","nm":"G","it":[{"ty":"el","p":{"a":0,"k":[0,0]},"s":{"a":0,"k":[104,104]},"d":1},{"ty":"fl","c":{"a":0,"k":[1,0.2,0.1,1]},"o":{"a":0,"k":100},"r":1},{"ty":"tr","p":{"a":0,"k":[0,0]},"a":{"a":0,"k":[0,0]},"s":{"a":0,"k":[100,100]},"r":{"a":0,"k":0},"o":{"a":0,"k":100}}]}]},
{"ddd":0,"ind":2,"ty":4,"nm":"Body","sr":1,"ao":0,"ip":0,"op":60,"st":0,"bm":0,"ks":{"o":{"a":0,"k":100},"r":{"a":0,"k":0},"p":{"a":0,"k":[70,76,0]},"a":{"a":0,"k":[0,0,0]},"s":{"a":1,"k":[{"t":0,"s":[97,97,100],"i":{"x":[0.5,0.5,0.5],"y":[0.5,0.5,0.5]},"o":{"x":[0.5,0.5,0.5],"y":[0.5,0.5,0.5]}},{"t":30,"s":[104,104,100],"i":{"x":[0.5,0.5,0.5],"y":[0.5,0.5,0.5]},"o":{"x":[0.5,0.5,0.5],"y":[0.5,0.5,0.5]}},{"t":60,"s":[97,97,100]}]}},"shapes":[
{"ty":"gr","nm":"Cap","it":[{"ty":"rc","p":{"a":0,"k":[0,-38]},"s":{"a":0,"k":[24,14]},"r":{"a":0,"k":4},"d":1},{"ty":"fl","c":{"a":0,"k":[0.35,0.37,0.42,1]},"o":{"a":0,"k":100},"r":1},{"ty":"tr","p":{"a":0,"k":[0,0]},"a":{"a":0,"k":[0,0]},"s":{"a":0,"k":[100,100]},"r":{"a":0,"k":0},"o":{"a":0,"k":100}}]},
{"ty":"gr","nm":"Sphere","it":[{"ty":"el","p":{"a":0,"k":[0,0]},"s":{"a":0,"k":[78,78]},"d":1},{"ty":"fl","c":{"a":0,"k":[0.12,0.13,0.16,1]},"o":{"a":0,"k":100},"r":1},{"ty":"st","c":{"a":0,"k":[0.28,0.3,0.35,1]},"o":{"a":0,"k":100},"w":{"a":0,"k":3}},{"ty":"tr","p":{"a":0,"k":[0,0]},"a":{"a":0,"k":[0,0]},"s":{"a":0,"k":[100,100]},"r":{"a":0,"k":0},"o":{"a":0,"k":100}}]},
{"ty":"gr","nm":"Cross1","it":[{"ty":"rc","p":{"a":0,"k":[0,4]},"s":{"a":0,"k":[28,7]},"r":{"a":0,"k":3},"d":1},{"ty":"fl","c":{"a":0,"k":[0.95,0.22,0.18,1]},"o":{"a":0,"k":100},"r":1},{"ty":"tr","p":{"a":0,"k":[0,4]},"a":{"a":0,"k":[0,4]},"s":{"a":0,"k":[100,100]},"r":{"a":0,"k":45},"o":{"a":0,"k":100}}]},
{"ty":"gr","nm":"Cross2","it":[{"ty":"rc","p":{"a":0,"k":[0,4]},"s":{"a":0,"k":[28,7]},"r":{"a":0,"k":3},"d":1},{"ty":"fl","c":{"a":0,"k":[0.95,0.22,0.18,1]},"o":{"a":0,"k":100},"r":1},{"ty":"tr","p":{"a":0,"k":[0,4]},"a":{"a":0,"k":[0,4]},"s":{"a":0,"k":[100,100]},"r":{"a":0,"k":-45},"o":{"a":0,"k":100}}]}
]},
{"ddd":0,"ind":3,"ty":4,"nm":"Spark","sr":1,"ao":0,"ip":0,"op":60,"st":0,"bm":0,"ks":{"o":{"a":1,"k":[{"t":0,"s":[100],"i":{"x":[0.5],"y":[0.5]},"o":{"x":[0.5],"y":[0.5]}},{"t":30,"s":[45],"i":{"x":[0.5],"y":[0.5]},"o":{"x":[0.5],"y":[0.5]}},{"t":60,"s":[100]}]},"r":{"a":1,"k":[{"t":0,"s":[0],"i":{"x":[0.5],"y":[0.5]},"o":{"x":[0.5],"y":[0.5]}},{"t":60,"s":[180]}]},"p":{"a":0,"k":[76,22,0]},"a":{"a":0,"k":[0,0,0]},"s":{"a":1,"k":[{"t":0,"s":[80,80,100],"i":{"x":[0.5,0.5,0.5],"y":[0.5,0.5,0.5]},"o":{"x":[0.5,0.5,0.5],"y":[0.5,0.5,0.5]}},{"t":30,"s":[130,130,100],"i":{"x":[0.5,0.5,0.5],"y":[0.5,0.5,0.5]},"o":{"x":[0.5,0.5,0.5],"y":[0.5,0.5,0.5]}},{"t":60,"s":[80,80,100]}]}},"shapes":[{"ty":"gr","nm":"S","it":[{"ty":"sr","sy":1,"d":1,"pt":{"a":0,"k":5},"p":{"a":0,"k":[0,0]},"r":{"a":0,"k":0},"ir":{"a":0,"k":5},"or":{"a":0,"k":14},"is":{"a":0,"k":0},"os":{"a":0,"k":0}},{"ty":"fl","c":{"a":0,"k":[1,0.78,0.15,1]},"o":{"a":0,"k":100},"r":1},{"ty":"tr","p":{"a":0,"k":[0,0]},"a":{"a":0,"k":[0,0]},"s":{"a":0,"k":[100,100]},"r":{"a":0,"k":0},"o":{"a":0,"k":100}}]}]}
]}
''';

const String _comboLottieJson = r'''
{"v":"5.7.4","fr":60,"ip":0,"op":40,"w":180,"h":180,"nm":"ComboBurst","ddd":0,"assets":[],"layers":[
{"ddd":0,"ind":1,"ty":4,"nm":"Ring","sr":1,"ao":0,"ip":0,"op":40,"st":0,"bm":0,"ks":{"o":{"a":1,"k":[{"t":0,"s":[100],"i":{"x":[0.2],"y":[1]},"o":{"x":[0.4],"y":[0]}},{"t":40,"s":[0]}]},"r":{"a":0,"k":0},"p":{"a":0,"k":[90,90,0]},"a":{"a":0,"k":[0,0,0]},"s":{"a":1,"k":[{"t":0,"s":[20,20,100],"i":{"x":[0.2,0.2,0.2],"y":[1,1,1]},"o":{"x":[0.4,0.4,0.4],"y":[0,0,0]}},{"t":40,"s":[155,155,100]}]}},"shapes":[{"ty":"gr","nm":"C","it":[{"ty":"el","p":{"a":0,"k":[0,0]},"s":{"a":0,"k":[100,100]},"d":1},{"ty":"st","c":{"a":0,"k":[1,0.85,0.25,1]},"o":{"a":0,"k":100},"w":{"a":0,"k":6}},{"ty":"tr","p":{"a":0,"k":[0,0]},"a":{"a":0,"k":[0,0]},"s":{"a":0,"k":[100,100]},"r":{"a":0,"k":0},"o":{"a":0,"k":100}}]}]},
{"ddd":0,"ind":2,"ty":4,"nm":"Star","sr":1,"ao":0,"ip":0,"op":40,"st":0,"bm":0,"ks":{"o":{"a":1,"k":[{"t":0,"s":[100],"i":{"x":[0.3],"y":[1]},"o":{"x":[0.5],"y":[0]}},{"t":40,"s":[0]}]},"r":{"a":1,"k":[{"t":0,"s":[0],"i":{"x":[0.3],"y":[1]},"o":{"x":[0.5],"y":[0]}},{"t":40,"s":[140]}]},"p":{"a":0,"k":[90,90,0]},"a":{"a":0,"k":[0,0,0]},"s":{"a":1,"k":[{"t":0,"s":[30,30,100],"i":{"x":[0.2,0.2,0.2],"y":[1,1,1]},"o":{"x":[0.4,0.4,0.4],"y":[0,0,0]}},{"t":40,"s":[140,140,100]}]}},"shapes":[{"ty":"gr","nm":"SS","it":[{"ty":"sr","sy":1,"d":1,"pt":{"a":0,"k":8},"p":{"a":0,"k":[0,0]},"r":{"a":0,"k":0},"ir":{"a":0,"k":22},"or":{"a":0,"k":56},"is":{"a":0,"k":0},"os":{"a":0,"k":0}},{"ty":"st","c":{"a":0,"k":[0.4,0.95,0.85,1]},"o":{"a":0,"k":100},"w":{"a":0,"k":4}},{"ty":"tr","p":{"a":0,"k":[0,0]},"a":{"a":0,"k":[0,0]},"s":{"a":0,"k":[100,100]},"r":{"a":0,"k":0},"o":{"a":0,"k":100}}]}]}
]}
''';

const String _explosionLottieJson = r'''
{"v":"5.7.4","fr":60,"ip":0,"op":45,"w":240,"h":240,"nm":"Explosion","ddd":0,"assets":[],"layers":[
{"ddd":0,"ind":1,"ty":4,"nm":"Wave","sr":1,"ao":0,"ip":0,"op":45,"st":0,"bm":0,"ks":{"o":{"a":1,"k":[{"t":0,"s":[100],"i":{"x":[0.2],"y":[1]},"o":{"x":[0.5],"y":[0]}},{"t":45,"s":[0]}]},"r":{"a":0,"k":0},"p":{"a":0,"k":[120,120,0]},"a":{"a":0,"k":[0,0,0]},"s":{"a":1,"k":[{"t":0,"s":[15,15,100],"i":{"x":[0.15,0.15,0.15],"y":[1,1,1]},"o":{"x":[0.4,0.4,0.4],"y":[0,0,0]}},{"t":45,"s":[200,200,100]}]}},"shapes":[{"ty":"gr","nm":"W","it":[{"ty":"el","p":{"a":0,"k":[0,0]},"s":{"a":0,"k":[110,110]},"d":1},{"ty":"fl","c":{"a":0,"k":[1,0.35,0.1,1]},"o":{"a":0,"k":65},"r":1},{"ty":"st","c":{"a":0,"k":[1,0.9,0.4,1]},"o":{"a":0,"k":100},"w":{"a":0,"k":8}},{"ty":"tr","p":{"a":0,"k":[0,0]},"a":{"a":0,"k":[0,0]},"s":{"a":0,"k":[100,100]},"r":{"a":0,"k":0},"o":{"a":0,"k":100}}]}]}
]}
''';

// ============================================================================
// 2. MODELOS DE FRUTAS Y ENTIDADES
// ============================================================================
class FruitType {
  final String name;
  final double radius;
  final Color rind, stripe, pith, flesh, juice, seeds;
  const FruitType({
    required this.name,
    required this.radius,
    required this.rind,
    required this.stripe,
    required this.pith,
    required this.flesh,
    required this.juice,
    required this.seeds,
  });
}

const List<FruitType> fruitTypes = [
  FruitType(
    name: 'Sandía', radius: 42,
    rind: Color(0xFF228B3B), stripe: Color(0xFF145823),
    pith: Color(0xFFD8F3C8), flesh: Color(0xFFFF3B4E),
    juice: Color(0xFFFF3B4E), seeds: Color(0xFF221515),
  ),
  FruitType(
    name: 'Naranja', radius: 36,
    rind: Color(0xFFE86F00), stripe: Color(0xFFFF8F1F),
    pith: Color(0xFFFFE6B8), flesh: Color(0xFFFFA31A),
    juice: Color(0xFFFF9500), seeds: Color(0xFFFFF6D6),
  ),
  FruitType(
    name: 'Manzana', radius: 35,
    rind: Color(0xFFD62828), stripe: Color(0xFFA61414),
    pith: Color(0xFFFFF3D6), flesh: Color(0xFFF8EAB8),
    juice: Color(0xFFFF5252), seeds: Color(0xFF4A2511),
  ),
  FruitType(
    name: 'Kiwi', radius: 32,
    rind: Color(0xFF7F5539), stripe: Color(0xFF5E3D28),
    pith: Color(0xFF9EF01A), flesh: Color(0xFF70E000),
    juice: Color(0xFF80ED19), seeds: Color(0xFF1B1B1B),
  ),
];

const FruitType goldenFruitType = FruitType(
  name: 'Dorada', radius: 50,
  rind: Color(0xFFF5B700), stripe: Color(0xFFD48800),
  pith: Color(0xFFFFF7CC), flesh: Color(0xFFFFCA28),
  juice: Color(0xFFFFD54F), seeds: Color(0xFFFFFBE6),
);

enum EntityKind { fruit, bomb, golden }
enum GameState { menu, playing, gameover }
enum GameMode { classic, timed }

class ActiveEntity {
  final int id;
  final EntityKind kind;
  final FruitType type;
  double x, y, vx, vy, radius, rotation, vr;
  bool sliced = false;
  int hits = 0;
  int lastHitMs = 0;
  double timer = 2.8;

  ActiveEntity({
    required this.id,
    required this.kind,
    required this.type,
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.radius,
    required this.rotation,
    required this.vr,
  });
}

class SlicedHalf {
  final FruitType type;
  final double radius;
  double x, y, vx, vy, spinAngle, vr;
  final int side;
  final double cutAngle, initialRotation;

  SlicedHalf({
    required this.type,
    required this.radius,
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.side,
    required this.cutAngle,
    required this.spinAngle,
    required this.initialRotation,
    required this.vr,
  });
}

class JuiceParticle {
  double x, y, vx, vy, r, life;
  final double maxLife;
  final Color color;
  JuiceParticle(this.x, this.y, this.vx, this.vy, this.r, this.color, this.life)
      : maxLife = life;
}

class FloatingText {
  final String text;
  double x, y, vy, life;
  final double maxLife, size;
  final Color color;
  FloatingText(this.text, this.x, this.y, this.vy, this.color, this.size, this.life)
      : maxLife = life;
}

class TrailPoint {
  final double x, y;
  final int timeMs;
  TrailPoint(this.x, this.y, this.timeMs);
}

class LottieOverlayEffect {
  final int id;
  final Uint8List bytes;
  final double x, y, size;
  double life;
  LottieOverlayEffect(this.id, this.bytes, this.x, this.y, this.size, this.life);
}

// ============================================================================
// 3. MOTOR PRINCIPAL FLUTTER
// ============================================================================
class FruitDojoGame extends StatefulWidget {
  const FruitDojoGame({super.key});
  @override
  State<FruitDojoGame> createState() => _FruitDojoGameState();
}

class _FruitDojoGameState extends State<FruitDojoGame> with TickerProviderStateMixin {
  static const double gravity = 1050.0;
  final math.Random _rng = math.Random();

  late final Uint8List _bombBytes = Uint8List.fromList(utf8.encode(_bombLottieJson));
  late final Uint8List _comboBytes = Uint8List.fromList(utf8.encode(_comboLottieJson));
  late final Uint8List _explosionBytes = Uint8List.fromList(utf8.encode(_explosionLottieJson));

  late final Ticker _ticker;
  Duration _lastElapsed = Duration.zero;
  double _W = 400, _H = 800;
  int _nextId = 1;

  GameState _state = GameState.menu;
  GameMode _mode = GameMode.timed;
  int _score = 0;
  int _highClassic = 0;
  int _highTimed = 0;
  int _lives = 3;
  double _timeLeft = 60.0;
  double _bonusRoundTimer = 0.0;
  double _bonusCooldown = 16.0;
  bool _goldenSpawned = false;
  int _levelNum = 1;

  double _waveTimer = 0.0;
  double _frenzySpawnTimer = 0.0;
  double _screenShake = 0.0;
  double _flashAlpha = 0.0;

  final List<ActiveEntity> _entities = [];
  final List<SlicedHalf> _halves = [];
  final List<JuiceParticle> _particles = [];
  final List<FloatingText> _texts = [];
  final List<LottieOverlayEffect> _lotties = [];
  final List<TrailPoint> _trail = [];

  int _comboCount = 0;
  double _comboTimer = 0.0;
  double _comboX = 0, _comboY = 0;
  double _menuTime = 0;
  int _lastSlashSoundMs = 0;

  @override
  void initState() {
    super.initState();
    SoundEffects.init();
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    final dt = _lastElapsed == Duration.zero
        ? 0.016
        : ((elapsed - _lastElapsed).inMicroseconds / 1e6).clamp(0.0, 0.05);
    _lastElapsed = elapsed;
    setState(() => _update(dt));
  }

  void _startGame(GameMode mode) {
    _mode = mode;
    _state = GameState.playing;
    SoundEffects.setMusicVolume(0.45);
    _score = 0;
    _lives = 3;
    _timeLeft = 60.0;
    _levelNum = 1;
    _bonusRoundTimer = 0.0;
    _bonusCooldown = 16.0;
    _goldenSpawned = false;
    _entities.clear();
    _halves.clear();
    _particles.clear();
    _texts.clear();
    _waveTimer = 0.45;
    _comboCount = 0;
  }

  void _triggerGameOver() {
    _state = GameState.gameover;
    SoundEffects.setMusicVolume(0.20);
    if (_mode == GameMode.classic && _score > _highClassic) _highClassic = _score;
    if (_mode == GameMode.timed && _score > _highTimed) _highTimed = _score;
  }

  void _spawnWave() {
    final diff = (_score / 60.0).clamp(0.0, 1.0);
    final count = 1 + _rng.nextInt(2 + (diff * 3).floor());
    for (int i = 0; i < count; i++) {
      final canBomb = _mode == GameMode.classic ? _score >= 3 : _score >= 5;
      final isBomb = canBomb && _rng.nextDouble() < (0.14 + diff * 0.14);
      final margin = math.min(90.0, _W * 0.18);
      final x = margin + _rng.nextDouble() * (_W - margin * 2);
      final targetX = _W * 0.22 + _rng.nextDouble() * (_W * 0.56);

      final peak = _H * (0.58 + _rng.nextDouble() * 0.24);
      final vy = -math.sqrt(2 * gravity * peak);
      final flightTime = (-vy * 2) / gravity;
      final vx = (targetX - x) / flightTime;

      final type = fruitTypes[_rng.nextInt(fruitTypes.length)];
      _entities.add(ActiveEntity(
        id: _nextId++,
        kind: isBomb ? EntityKind.bomb : EntityKind.fruit,
        type: type,
        x: x,
        y: _H + 60 + i * 30,
        vx: vx,
        vy: vy,
        radius: isBomb ? 38 : type.radius,
        rotation: _rng.nextDouble() * math.pi * 2,
        vr: (_rng.nextDouble() - 0.5) * 5,
      ));
    }
  }

  void _spawnFrenzyFruit() {
    final left = _rng.nextBool();
    final x = left ? -30.0 : _W + 30.0;
    final y = _H * (0.45 + _rng.nextDouble() * 0.35);
    final vx = (left ? 1 : -1) * (_W * (0.35 + _rng.nextDouble() * 0.28));
    final vy = -(420 + _rng.nextDouble() * 280);
    final type = fruitTypes[_rng.nextInt(fruitTypes.length)];
    _entities.add(ActiveEntity(
      id: _nextId++,
      kind: EntityKind.fruit,
      type: type,
      x: x, y: y, vx: vx, vy: vy,
      radius: type.radius,
      rotation: _rng.nextDouble() * math.pi * 2,
      vr: (_rng.nextDouble() - 0.5) * 7,
    ));
  }

  void _startBonusRound() {
    _levelNum++;
    _bonusRoundTimer = 6.5;
    _bonusCooldown = 18.0;
    HapticFeedback.mediumImpact();
    SoundEffects.playCombo();
    SoundEffects.setMusicVolume(0.55);
    _lotties.add(LottieOverlayEffect(_nextId++, _comboBytes, _W / 2, _H * 0.35, 260, 0.9));
    _texts.add(FloatingText(
      '★ NIVEL BONUS ${_levelNum - 1}: ¡FRENESÍ! ★',
      _W / 2, _H * 0.32, -20, const Color(0xFFFFD54F), 24, 1.8,
    ));
  }

  void _spawnGoldenFruit() {
    final left = _rng.nextBool();
    _entities.add(ActiveEntity(
      id: _nextId++,
      kind: EntityKind.golden,
      type: goldenFruitType,
      x: left ? -40 : _W + 40,
      y: _H * 0.55,
      vx: left ? _W * 0.28 : -_W * 0.28,
      vy: -360,
      radius: 52,
      rotation: 0,
      vr: 2.2,
    ));
    _texts.add(FloatingText(
      '⚡ ¡CORTA LA FRUTA DORADA! ⚡',
      _W / 2, _H * 0.24, -18, const Color(0xFFFFE066), 21, 1.8,
    ));
  }

  void _sliceEntity(ActiveEntity ent, double cutAngle, int nowMs) {
    if (ent.kind == EntityKind.golden) {
      if (nowMs - ent.lastHitMs < 75) return;
      ent.lastHitMs = nowMs;
      ent.hits++;
      _score += 2;
      _screenShake = 6;
      HapticFeedback.lightImpact();
      SoundEffects.playSplat();
      for (int i = 0; i < 8; i++) {
        final a = _rng.nextDouble() * math.pi * 2;
        final spd = 140 + _rng.nextDouble() * 220;
        _particles.add(JuiceParticle(ent.x, ent.y, math.cos(a) * spd, math.sin(a) * spd, 4, const Color(0xFFFFE066), 0.45));
      }
      _texts.add(FloatingText('${ent.hits} HITS! +2', ent.x, ent.y - 35, -70, const Color(0xFFFFE066), 20, 0.5));
      return;
    }

    ent.sliced = true;

    if (ent.kind == EntityKind.bomb) {
      HapticFeedback.heavyImpact();
      SoundEffects.playBomb();
      _screenShake = 24;
      _flashAlpha = 0.85;
      _lotties.add(LottieOverlayEffect(_nextId++, _explosionBytes, ent.x, ent.y, 260, 0.9));
      for (int i = 0; i < 24; i++) {
        final a = _rng.nextDouble() * math.pi * 2;
        final spd = 160 + _rng.nextDouble() * 440;
        _particles.add(JuiceParticle(ent.x, ent.y, math.cos(a) * spd, math.sin(a) * spd, 5, const Color(0xFFFF8C1A), 0.7));
      }
      if (_mode == GameMode.classic) {
        _entities.clear();
        _triggerGameOver();
      } else {
        _score = math.max(0, _score - 10);
        _comboCount = 0;
        _texts.add(FloatingText('-10 PTS', ent.x, ent.y - 20, -60, const Color(0xFFFF4D5A), 30, 1.0));
      }
      return;
    }

    HapticFeedback.lightImpact();
    SoundEffects.playSplat();
    final pts = _bonusRoundTimer > 0 ? 2 : 1;
    _score += pts;
    _comboCount++;
    _comboTimer = 0.16;
    _comboX = ent.x;
    _comboY = ent.y;

    for (int i = 0; i < 14; i++) {
      final a = cutAngle + (_rng.nextDouble() - 0.5) * 2.2;
      final spd = 120 + _rng.nextDouble() * 300;
      _particles.add(JuiceParticle(ent.x, ent.y, math.cos(a) * spd, math.sin(a) * spd - 60, 4.5, ent.type.juice, 0.6));
    }

    final perp = cutAngle + math.pi / 2;
    for (final side in [-1, 1]) {
      _halves.add(SlicedHalf(
        type: ent.type,
        radius: ent.radius,
        x: ent.x + math.cos(perp) * side * 6,
        y: ent.y + math.sin(perp) * side * 6,
        vx: ent.vx + math.cos(perp) * side * 135,
        vy: ent.vy + math.sin(perp) * side * 135 - 60,
        side: side,
        cutAngle: cutAngle,
        spinAngle: cutAngle,
        initialRotation: ent.rotation,
        vr: side * (2.5 + _rng.nextDouble() * 2.5),
      ));
    }
    _texts.add(FloatingText('+$pts', ent.x, ent.y - 20, -80, pts > 1 ? const Color(0xFFFFD54F) : Colors.white, 24, 0.6));
  }

  void _flushCombo() {
    if (_comboCount >= 3) {
      SoundEffects.playCombo();
      final bonus = _comboCount;
      _score += bonus;
      _lotties.add(LottieOverlayEffect(_nextId++, _comboBytes, _comboX, _comboY, 200, 0.8));
      _texts.add(FloatingText(
        '¡COMBO x$_comboCount! +$bonus',
        _comboX.clamp(110.0, math.max(110.0, _W - 110.0)),
        math.max(_comboY - 30, 90),
        -55, const Color(0xFFFFE066), 25, 1.1,
      ));
    }
    _comboCount = 0;
  }

  void _update(double dt) {
    _menuTime += dt;
    if (_comboTimer > 0) {
      _comboTimer -= dt;
      if (_comboTimer <= 0) _flushCombo();
    }
    if (_screenShake > 0) _screenShake = math.max(0, _screenShake - dt * 55);
    if (_flashAlpha > 0) _flashAlpha = math.max(0, _flashAlpha - dt * 2.2);

    if (_state == GameState.playing) {
      if (_mode == GameMode.timed) {
        if (_bonusRoundTimer > 0) {
          _bonusRoundTimer -= dt;
          _frenzySpawnTimer -= dt;
          if (_frenzySpawnTimer <= 0) {
            _spawnFrenzyFruit();
            _frenzySpawnTimer = 0.22;
          }
          if (_bonusRoundTimer <= 0) {
            SoundEffects.setMusicVolume(0.45);
          }
        } else {
          _timeLeft -= dt;
          _bonusCooldown -= dt;
          if (_timeLeft <= 0) {
            _timeLeft = 0;
            _triggerGameOver();
          } else {
            if (_bonusCooldown <= 0 && _timeLeft > 8) _startBonusRound();
            if (!_goldenSpawned && _timeLeft <= 12) {
              _goldenSpawned = true;
              _spawnGoldenFruit();
            }
          }
        }
      }

      if (_bonusRoundTimer <= 0 && _state == GameState.playing) {
        _waveTimer -= dt;
        if (_waveTimer <= 0) {
          _spawnWave();
          _waveTimer = math.max(0.85, 2.0 - math.min(_score, 60) * 0.016);
        }
      }

      for (final ent in _entities) {
        if (ent.kind == EntityKind.golden) {
          ent.x += ent.vx * dt;
          ent.y += ent.vy * dt;
          ent.vy += (gravity * 0.35) * dt;
          if (ent.x < ent.radius || ent.x > _W - ent.radius) ent.vx *= -1;
          if (ent.y > _H * 0.72) ent.vy = -ent.vy.abs() * 0.85;
          ent.rotation += ent.vr * dt;
          ent.timer -= dt;
          if (ent.timer <= 0) {
            ent.sliced = true;
            final bonus = ent.hits * 2;
            _score += bonus;
            _screenShake = 16;
            _lotties.add(LottieOverlayEffect(_nextId++, _comboBytes, ent.x, ent.y, 260, 0.9));
            _texts.add(FloatingText('¡GRANADA x${ent.hits}! +$bonus', ent.x, ent.y, -45, const Color(0xFFFFD54F), 26, 1.4));
          }
          continue;
        }
        ent.x += ent.vx * dt;
        ent.y += ent.vy * dt;
        ent.vy += gravity * dt;
        ent.rotation += ent.vr * dt;

        if (_mode == GameMode.classic && !ent.sliced && ent.kind == EntityKind.fruit && ent.vy > 0 && ent.y > _H + 80) {
          ent.sliced = true;
          _lives--;
          if (_lives <= 0) _triggerGameOver();
        }
      }
      _entities.removeWhere((e) => e.sliced || e.y > _H + 190);
    }

    for (final h in _halves) {
      h.x += h.vx * dt;
      h.y += h.vy * dt;
      h.vy += gravity * dt;
      h.spinAngle += h.vr * dt;
    }
    _halves.removeWhere((h) => h.y > _H + 150);

    for (final p in _particles) {
      p.x += p.vx * dt;
      p.y += p.vy * dt;
      p.vy += gravity * 0.6 * dt;
      p.life -= dt;
    }
    _particles.removeWhere((p) => p.life <= 0);

    for (final t in _texts) {
      t.y += t.vy * dt;
      t.life -= dt;
    }
    _texts.removeWhere((t) => t.life <= 0);

    for (final l in _lotties) l.life -= dt;
    _lotties.removeWhere((l) => l.life <= 0);

    final nowMs = DateTime.now().millisecondsSinceEpoch;
    _trail.removeWhere((p) => nowMs - p.timeMs > 140);
  }

  double _distSegmentPoint(double x1, double y1, double x2, double y2, double px, double py) {
    final dx = x2 - x1, dy = y2 - y1;
    final lenSq = dx * dx + dy * dy;
    if (lenSq == 0) return _hypot(px - x1, py - y1);
    final t = (((px - x1) * dx + (py - y1) * dy) / lenSq).clamp(0.0, 1.0);
    return _hypot(px - (x1 + t * dx), py - (y1 + t * dy));
  }

  void _handleSwipe(double x1, double y1, double x2, double y2, int nowMs) {
    final swipeDist = _hypot(x2 - x1, y2 - y1);
    if (swipeDist < 4) return;
    final cutAngle = math.atan2(y2 - y1, x2 - x1);

    if (swipeDist > 28 && nowMs - _lastSlashSoundMs > 110) {
      _lastSlashSoundMs = nowMs;
      SoundEffects.playSlash();
    }

    if (_state == GameState.menu) {
      final gap = math.min(115.0, _W * 0.25);
      final leftX = _W / 2 - gap, rightX = _W / 2 + gap;
      final y = _H * 0.58;
      if (_distSegmentPoint(x1, y1, x2, y2, leftX, y) <= 52) {
        SoundEffects.playSplat();
        _startGame(GameMode.classic);
        return;
      }
      if (_distSegmentPoint(x1, y1, x2, y2, rightX, y) <= 54) {
        SoundEffects.playSplat();
        _startGame(GameMode.timed);
        return;
      }
      return;
    }

    if (_state == GameState.gameover) return;

    for (final ent in _entities) {
      if (ent.sliced) continue;
      if (_distSegmentPoint(x1, y1, x2, y2, ent.x, ent.y) <= ent.radius * 1.1) {
        _sliceEntity(ent, cutAngle, nowMs);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          _W = constraints.maxWidth;
          _H = constraints.maxHeight;
          return Stack(
            children: [
              Listener(
                onPointerDown: (e) {
                  if (_state == GameState.gameover) {
                    setState(() {
                      _state = GameState.menu;
                      SoundEffects.setMusicVolume(0.38);
                    });
                    return;
                  }
                  _trail.clear();
                  _trail.add(TrailPoint(e.localPosition.dx, e.localPosition.dy, DateTime.now().millisecondsSinceEpoch));
                },
                onPointerMove: (e) {
                  final nowMs = DateTime.now().millisecondsSinceEpoch;
                  final x = e.localPosition.dx, y = e.localPosition.dy;
                  if (_trail.isNotEmpty) {
                    final prev = _trail.last;
                    _handleSwipe(prev.x, prev.y, x, y, nowMs);
                  }
                  _trail.add(TrailPoint(x, y, nowMs));
                },
                onPointerUp: (_) => _flushCombo(),
                onPointerCancel: (_) => _flushCombo(),
                child: Stack(
                  children: [
                    CustomPaint(
                      size: Size(_W, _H),
                      painter: _DojoPainter(this),
                    ),
                    // Bombas animadas nativamente con Lottie
                    ..._entities.where((e) => e.kind == EntityKind.bomb).map((b) => Positioned(
                      key: ValueKey(b.id),
                      left: b.x - 65,
                      top: b.y - 65,
                      width: 130,
                      height: 130,
                      child: IgnorePointer(
                        child: Lottie.memory(_bombBytes, repeat: true),
                      ),
                    )),
                    // Explosiones y combos Lottie
                    ..._lotties.map((l) => Positioned(
                      key: ValueKey(l.id),
                      left: l.x - l.size / 2,
                      top: l.y - l.size / 2,
                      width: l.size,
                      height: l.size,
                      child: IgnorePointer(
                        child: Lottie.memory(l.bytes, repeat: false),
                      ),
                    )),
                  ],
                ),
              ),
              // Botón de activar/desactivar música dojo
              Positioned(
                top: 14,
                right: 14,
                child: SafeArea(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        SoundEffects.toggleMusic();
                      });
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: SoundEffects.musicEnabled ? const Color(0xFFFFD166) : Colors.white30,
                          width: 1.6,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black45,
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        SoundEffects.musicEnabled ? Icons.music_note_rounded : Icons.music_off_rounded,
                        color: SoundEffects.musicEnabled ? const Color(0xFFFFD166) : Colors.white54,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DojoPainter extends CustomPainter {
  final _FruitDojoGameState g;
  _DojoPainter(this.g);

  void _drawFruit(Canvas canvas, FruitType type, double r, bool inside, bool golden) {
    if (golden) {
      canvas.drawCircle(Offset.zero, r + 8, Paint()..color = const Color(0x55FFD54F)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14));
    }
    canvas.drawCircle(Offset.zero, r, Paint()..color = type.rind);

    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: Offset.zero, radius: r)));
    final stripePaint = Paint()..color = type.stripe..style = PaintingStyle.stroke..strokeWidth = r * 0.14;
    for (int i = -2; i <= 2; i++) {
      canvas.drawCircle(Offset(i * r * 0.45, 0), r * 0.9, stripePaint);
    }
    canvas.restore();

    if (inside) {
      canvas.drawCircle(Offset.zero, r * 0.87, Paint()..color = type.pith);
      canvas.drawCircle(Offset.zero, r * 0.78, Paint()..color = type.flesh);
      final seedPaint = Paint()..color = type.seeds;
      for (int i = 0; i < 8; i++) {
        final a = (i / 8) * math.pi * 2;
        canvas.save();
        canvas.translate(math.cos(a) * r * 0.44, math.sin(a) * r * 0.44);
        canvas.rotate(a);
        canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: r * 0.16, height: r * 0.08), seedPaint);
        canvas.restore();
      }
    } else {
      canvas.save();
      canvas.translate(-r * 0.3, -r * 0.32);
      canvas.rotate(-math.pi / 4);
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: r * 0.56, height: r * 0.28),
        Paint()..color = Colors.white.withValues(alpha: 0.32),
      );
      canvas.restore();
    }
  }

  void _drawText(Canvas canvas, String text, double x, double y, Color color, double size, {TextAlign align = TextAlign.center}) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: color, fontSize: size, fontWeight: FontWeight.bold, shadows: const [Shadow(blurRadius: 8, color: Colors.black87)]),
      ),
      textAlign: align,
      textDirection: TextDirection.ltr,
    )..layout();
    double dx = x;
    if (align == TextAlign.center) dx -= tp.width / 2;
    if (align == TextAlign.right) dx -= tp.width;
    tp.paint(canvas, Offset(dx, y));
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    canvas.save();
    if (g._screenShake > 0) {
      canvas.translate((g._rng.nextDouble() - 0.5) * g._screenShake, (g._rng.nextDouble() - 0.5) * g._screenShake);
    }

    // Fondo dojo madera
    final bgPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0, -0.2),
        radius: 0.9,
        colors: [g._bonusRoundTimer > 0 ? const Color(0xFF5C3C0E) : const Color(0xFF54321C), const Color(0xFF241208)],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), bgPaint);

    final plankPaint = Paint()..color = Colors.black26..strokeWidth = 2;
    for (double x = 0; x < w; x += 100) {
      canvas.drawLine(Offset(x, 0), Offset(x, h), plankPaint);
    }

    if (g._state == GameState.menu) {
      final gap = math.min(115.0, w * 0.25);
      final y = h * 0.58 + math.sin(g._menuTime * 3) * 8;
      canvas.save();
      canvas.translate(w / 2 - gap, y);
      canvas.rotate(g._menuTime * 1.1);
      _drawFruit(canvas, fruitTypes[0], 48, false, false);
      canvas.restore();

      canvas.save();
      canvas.translate(w / 2 + gap, y);
      canvas.rotate(-g._menuTime * 1.3);
      _drawFruit(canvas, goldenFruitType, 52, false, true);
      canvas.restore();

      _drawText(canvas, 'FRUIT DOJO', w / 2, h * 0.20, const Color(0xFFFFE5B4), math.min(50, w * 0.11));
      _drawText(canvas, 'Corta una fruta para elegir modo', w / 2, h * 0.30, const Color(0xFF5EF2C6), 17);
      _drawText(canvas, 'CLÁSICO\nRécord: ${g._highClassic}', w / 2 - gap, y + 66, Colors.white, 15);
      _drawText(canvas, 'TIEMPO + BONUS\nRécord: ${g._highTimed}', w / 2 + gap, y + 66, const Color(0xFFFFD54F), 15);
    }

    // Mitades cortadas con ángulo exacto
    for (final half in g._halves) {
      canvas.save();
      canvas.translate(half.x, half.y);
      canvas.rotate(half.spinAngle);
      canvas.clipRect(half.side == -1
          ? Rect.fromLTWH(-half.radius * 1.5, -half.radius * 1.5, half.radius * 3, half.radius * 1.5)
          : Rect.fromLTWH(-half.radius * 1.5, 0, half.radius * 3, half.radius * 1.5));
      canvas.rotate(half.initialRotation - half.cutAngle);
      _drawFruit(canvas, half.type, half.radius, true, false);
      canvas.restore();
    }

    // Frutas activas (las bombas las dibuja Lottie en el Stack)
    for (final ent in g._entities) {
      if (ent.kind == EntityKind.bomb) continue;
      canvas.save();
      canvas.translate(ent.x, ent.y);
      canvas.rotate(ent.rotation);
      _drawFruit(canvas, ent.type, ent.radius, false, ent.kind == EntityKind.golden);
      canvas.restore();
    }

    // Partículas de jugo
    for (final p in g._particles) {
      final a = (p.life / p.maxLife).clamp(0.0, 1.0);
      canvas.drawCircle(Offset(p.x, p.y), p.r, Paint()..color = p.color.withValues(alpha: a));
    }

    // Textos flotantes
    for (final t in g._texts) {
      final a = (t.life / t.maxLife).clamp(0.0, 1.0);
      _drawText(canvas, t.text, t.x, t.y, t.color.withValues(alpha: a), t.size);
    }

    // Estela de corte
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    for (int i = 1; i < g._trail.length; i++) {
      final p0 = g._trail[i - 1], p1 = g._trail[i];
      final alpha = (1 - (nowMs - p1.timeMs) / 140).clamp(0.0, 1.0);
      final width = (i / g._trail.length) * 12 * alpha;
      canvas.drawLine(
        Offset(p0.x, p0.y), Offset(p1.x, p1.y),
        Paint()..color = const Color(0xFF5EF2C6).withValues(alpha: alpha * 0.65)..strokeWidth = width + 6..strokeCap = StrokeCap.round,
      );
      canvas.drawLine(
        Offset(p0.x, p0.y), Offset(p1.x, p1.y),
        Paint()..color = Colors.white.withValues(alpha: alpha)..strokeWidth = math.max(2, width)..strokeCap = StrokeCap.round,
      );
    }

    // HUD
    if (g._state == GameState.playing || g._state == GameState.gameover) {
      _drawText(canvas, '${g._score}', 24, 44, const Color(0xFFFFD166), 40, align: TextAlign.left);
      if (g._mode == GameMode.classic) {
        for (int i = 0; i < 3; i++) {
          _drawText(canvas, '✕', w - 76 - i * 30, 48, i >= g._lives ? const Color(0xFFFF3B4E) : Colors.white24, 28, align: TextAlign.right);
        }
      } else {
        final label = g._bonusRoundTimer > 0
            ? '★ BONUS ${g._bonusRoundTimer.toStringAsFixed(1)}s'
            : '${g._timeLeft.ceil()}s';
        final col = g._bonusRoundTimer > 0 ? const Color(0xFFFFD54F) : (g._timeLeft <= 10 ? const Color(0xFFFF4D5A) : const Color(0xFF5EF2C6));
        _drawText(canvas, label, w - 76, 46, col, 32, align: TextAlign.right);
      }
    }

    if (g._state == GameState.gameover) {
      canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..color = Colors.black54);
      _drawText(canvas, g._mode == GameMode.timed ? '¡TIEMPO AGOTADO!' : '¡GAME OVER!', w / 2, h * 0.38, const Color(0xFFFF4D5A), 38);
      _drawText(canvas, 'Puntuación: ${g._score}', w / 2, h * 0.48, const Color(0xFFFFD166), 28);
      _drawText(canvas, 'Toca para volver al menú', w / 2, h * 0.58, Colors.white, 18);
    }

    if (g._flashAlpha > 0) {
      canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..color = Colors.white.withValues(alpha: g._flashAlpha));
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}