class Memo {
  /*
  * メモデータ
  * 
  * テーブル定義とは別物。
  */ 
  Memo({
    required this.orderId,
    required this.memoId,
    this.memoPreview,
    this.memo,
    required this.backColor,
  });

  int orderId;
  String memoId;
  String? memoPreview;
  String? memo;
  int backColor;


  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'memoId': memoId,
      'memoPreview': memoPreview,
      'memo': memo,
      'backColor': backColor,
    };
  }

  @override
  String toString() {
    return 'Memo{orderId: $orderId, memoId: $memoId, memoPreview: $memoPreview, memo: $memo, backColor: $backColor}';
  }

}
