import 'package:dart_mock/dart_mock.dart' as mock;
import 'package:ai_assistant/screens/base/kit/index.dart';

class MockMine {
  final String nickName;
  final String avatar;
  final int createDay;
  final List<String> tags;
  final String bg;
  final int visits;
  final int friends;
  final int fans;

  MockMine({
    required this.nickName,
    required this.avatar,
    required this.createDay,
    required this.tags,
    required this.bg,
    required this.visits,
    required this.friends,
    required this.fans,
  });

  static MockMine get() {
    return MockMine(
      nickName: mock.cname(),
      avatar: WcaoUtils.getRandomImage(),
      createDay: mock.integer(min: 1, max: 99),
      tags: List.generate(
        mock.integer(min: 1, max: 4),
        (index) => '#${mock.ctitle(min: 3, max: 10)}',
      ),
      bg: WcaoUtils.getRandomImage(),
      visits: mock.integer(min: 1, max: 99),
      friends: mock.integer(min: 1, max: 99),
      fans: mock.integer(min: 1, max: 99),
    );
  }
}

class MockHistoryMatch {
  static final List<MockHistoryMatch> _data = [];

  final String nickName;
  final int age;

  ///  女 男 其他
  final String sex;
  final String constellation;
  final String avatar;

  MockHistoryMatch({
    required this.nickName,
    required this.age,
    required this.sex,
    required this.constellation,
    required this.avatar,
  });

  static List<MockHistoryMatch> get() {
    for (var i = 0; i < 12; i++) {
      _data.add(
        MockHistoryMatch(
          nickName: mock.cname(),
          age: mock.integer(min: 18, max: 45),
          sex: mock.pick(["女", "男", "其他"]),
          constellation: mock.pick([
            "白羊座",
            "金牛座",
            "双子座",
            "巨蟹座",
            "狮子座",
            "处女座",
            "天秤座",
            "天蝎座",
            "射手座",
            "摩羯座",
            "水瓶座",
            "双鱼座",
          ]),
          avatar: WcaoUtils.getRandomImage(),
        ),
      );
    }

    return _data;
  }

  static clean() {
    _data.clear();
  }
}

class MockLike extends MockHistoryMatch {
  MockLike({
    required String nickName,
    required int age,
    required String sex,
    required String constellation,
    required String avatar,
    required this.time,
    required this.text,
    required this.mediaType,
    required this.media,
    required this.tag,
    required this.share,
    required this.fav,
    required this.comment,
  }) : super(
         nickName: nickName,
         age: age,
         sex: sex,
         constellation: constellation,
         avatar: avatar,
       );

  static final List<MockLike> _data = [];

  /// 时间
  final String time;

  /// 发布内容
  final String text;

  /// 多媒体类型
  /// true: 视频
  /// false: 图片
  final bool mediaType;

  /// 多媒体
  final List<String> media;

  /// 标签
  final List<String> tag;

  final int share;

  final int fav;

  final int comment;

  static List<MockLike> get({int num = 12}) {
    for (var i = 0; i < num; i++) {
      var mockType = mock.boolean();
      _data.add(
        MockLike(
          nickName: mock.cname(),
          age: mock.integer(min: 18, max: 45),
          sex: mock.pick(["女", "男", "其他"]),
          constellation: mock.pick([
            "白羊座",
            "金牛座",
            "双子座",
            "巨蟹座",
            "狮子座",
            "处女座",
            "天秤座",
            "天蝎座",
            "射手座",
            "摩羯座",
            "水瓶座",
            "双鱼座",
          ]),
          avatar: WcaoUtils.getRandomImage(),
          tag: List.generate(
            mock.integer(min: 1, max: 4),
            (index) => '#${mock.ctitle(min: 3, max: 10)}',
          ),
          mediaType: mockType,
          media: List.generate(mock.integer(min: 0, max: 4), (index) {
            if (mockType) {
              return WcaoUtils.getRandomImage();
            } else {
              return WcaoUtils.getRandomImage();
            }
          }),
          share: mock.integer(min: 1, max: 99),
          fav: mock.integer(min: 1, max: 99),
          comment: mock.integer(min: 1, max: 99),
          text: mock.cparagraph(min: 1, max: 4),
          time: mock.dateTime(start: DateTime(2022)).toIso8601String(),
        ),
      );
    }

    return _data;
  }

  static clear() {
    _data.clear();
  }
}
