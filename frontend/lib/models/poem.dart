class Poem {
  final int id;
  final String name;
  final String author;
  final String? content; // 正文
  final String? note; // 注释
  final String? modernChinese; // 白话文
  final String? comment; // 赏析

  Poem({
    required this.id,
    required this.name,
    required this.author,
    this.content,
    this.note,
    this.modernChinese,
    this.comment,
  });

  factory Poem.fromJson(Map<String, dynamic> json) {
    return Poem(
      id: json['id'],
      name: json['name'],
      author: json['author'],
      content: json['content'] ?? '',
      note: json['note'] ?? '',
      modernChinese: json['modernChinese'] ?? '',
      comment: json['comment'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'author': author,
      'content': content,
      'note': note,
      'modernChinese': modernChinese,
      'comment': comment,
    };
  }

  Poem copyWith({
    int? id,
    String? name,
    String? author,
    String? content,
    String? note,
    String? modernChinese,
    String? comment,
  }) {
    return Poem(
      id: id ?? this.id,
      name: name ?? this.name,
      author: author ?? this.author,
      content: content ?? this.content,
      note: note ?? this.note,
      modernChinese: modernChinese ?? this.modernChinese,
      comment: comment ?? this.comment,
    );
  }
}

class ApiResult<T> {
  final int code;
  final String msg;
  final T? data;

  ApiResult({required this.code, required this.msg, this.data});

  factory ApiResult.fromJson(
    Map<String, dynamic> json, {
    T Function(dynamic)? dataDecoder,
  }) {
    return ApiResult<T>(
      code: json['code'] ?? 500,
      msg: json['msg'] ?? '未知错误',
      data: json['data'] != null && dataDecoder != null
          ? dataDecoder(json['data'])
          : null,
    );
  }

  bool get isSuccess => code == 200;
}
