import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'package:tag_memo/data/sqlite/memo.dart';


final Future<Database> database = getDatabasesPath().then((String path) {

  return openDatabase(
    join(path, 'memo_database.db'),
    onCreate: (Database db, int version) async {
      /**
       * memo.id: "yyyymmdd-hhmmss"
       * memo.memo: free
       * memo.backColor: 50, 100, 200, 300, 400, 500, 600, 700, 800, 900
       */
      await db.execute(
        '''
        CREATE TABLE memo(
          id TEXT PRIMARY KEY, 
          memo TEXT, 
          backColor INTEGER,
          delDateTime TEXT
        )
        '''
      );
      /**
       * メモが存在するもののみレコード登録。
       * memoOrder.id: 配列のインデックス。
       * memoOrder.memoId: = memo.id
       */
      await db.execute(
        '''
        CREATE TABLE memoOrder(
          id INTEGER PRIMARY KEY, 
          memoId TEXT, 
          FOREIGN KEY(memoId) REFERENCES memo(id)
        )
        '''
      );
      // テスト用
      await db.execute('INSERT INTO memo (id, memo, backColor) VALUES ("20240101-000000", "サンプルサンプルサンプルサンプル\nサンプル", 600)');
      await db.execute('INSERT INTO memoOrder (id, memoId) VALUES (0, "20240101-000000")');
      await db.execute('INSERT INTO memo (id, memo, backColor) VALUES ("20240101-000001", "サンプルサンプルサンプルサンプル\nサンプル", 500)');
      await db.execute('INSERT INTO memoOrder (id, memoId) VALUES (1, "20240101-000001")');
      await db.execute('INSERT INTO memo (id, memo, backColor) VALUES ("20250101-000001", "サンプルサンプルサンプルサンプル\nサンプル", 500)');
      await db.execute('INSERT INTO memoOrder (id, memoId) VALUES (2, "20250101-000001")');

    },
    version: 1,
  );

});

/* メモプレビュー取得用 */
Future<List<Memo?>> getMemoPreview({String orderby='asc'}) async {
  final db = await database;
  // DBからデータリストを取得
  final List<Map<String, dynamic>> maps = await db.rawQuery(
    '''
    SELECT mO.id AS orderId, mO.memoId, SUBSTR(m.memo, 1, 150) AS memoPreview, m.backColor 
    FROM memoOrder AS mO 
    LEFT OUTER JOIN memo AS m 
    ON mO.memoId = m.id 
    ORDER BY mO.id $orderby
    ''',
  );

  /** 空白データをnullで埋めつつ、プレビューデータを配列に */
  final previewList = <Memo?>[];  // プレビューデータ配列
  var indexCount = 0;             // プレビューデータインデックスカウント用
  for (var i = 0; i < maps.length; i++) {
    // DBから取得したデータの前に挿入すべき空白データをnullで埋める。
    for(; indexCount < (maps[i]['orderId'] as int); indexCount++){
      previewList.add(null);
    }
    // DBから取得したデータを配列に追加
    previewList.add(Memo(
      orderId: maps[i]['orderId'] as int,
      memoId: maps[i]['memoId'] as String,
      memoPreview: maps[i]['memoPreview'] as String?,
      backColor: maps[i]['backColor'] as int,
    ),);
    // DBから取得したデータ分のインデックスをカウントアップ
    indexCount++;
  }

  return previewList;
}

/* メモ取得用 */
Future<Memo> getMemo(String memoId) async {
  final db = await database;
  // メモデータを取得
  final List<Map<String, dynamic>> maps = await db.rawQuery(
    '''
    SELECT mO.id AS orderId, mO.memoId, m.memo, m.backColor 
    FROM memoOrder AS mO 
    LEFT OUTER JOIN memo AS m 
    ON mO.memoId = m.id 
    WHERE mO.memoId = ?
    ''',
    [memoId],
  );

  final memo = Memo(
    orderId: maps[0]['orderId'] as int,
    memoId: maps[0]['memoId'] as String,
    memo: maps[0]['memo'] as String?,
    backColor: maps[0]['backColor'] as int,
  );

  return memo;
}

/* メモ新規作成 */
Future<void> insertMemo(Memo memo) async {
  final db = await database;

  final memoId = DateFormat('yyyyMMdd-HHmmss').format(DateTime.now());
  /** memoテーブルに登録 */
  await db.rawInsert(
    'INSERT INTO memo(id, memo, backColor) VALUES (?, ?, ?)',
    [memoId, memo.memo, memo.backColor],
  );

  /** orderIdを取得 */
  final orderId = await getNewOrderId();

  /** memoOrderテーブルに登録 */
  await db.rawInsert(
    'INSERT INTO memoOrder(id, memoId) VALUES (?, ?)',
    [orderId, memoId],
  );
}

/* メモ更新 */
Future<void> updateMemo(Memo memo) async {
  final db = await database;

  await db.rawUpdate(
    'UPDATE memo SET memo = ?, backColor = ? WHERE id = ?',
    [memo.memo, memo.backColor, memo.memoId],
  );
}

/* 一番最初の空白データのインデックスを取得 */
Future<int> getNewOrderId() async {
  final db = await database;
  // memoOrderの全レコードを昇順で取得
  final List<Map<String, dynamic>> maps = await db.rawQuery(
    'SELECT id FROM memoOrder ORDER BY id asc',
  );

  var orderId = -1;
  for (var i = 0; i < maps.length; i++) {
    // 空白データが見つかったらそこをorderIdとする。
    if(maps[i]['id'] != i){
      orderId = i;
      break; 
    }
  }
  // 空白データがない場合、一番大きいorderId+1をorderIdとする。
  if(orderId == -1){
    orderId = maps[maps.length-1]['id'] as int;
    orderId++;
  }

  return orderId;
}

/* メモ論理削除 */
Future<void> deleteMemoOrder(String memoId) async {
  final db = await database;
  /** memoOrderのレコードを削除 */
  await db.delete('memoOrder', where: 'memoId = ?', whereArgs: [memoId]);
  /** memoのdelDateTimeを削除した日付で更新 */
  final delDateTime = DateFormat('yyyyMMdd-HHmmss').format(DateTime.now());
  await db.rawUpdate(
    'UPDATE memo SET delDateTime = ? WHERE id = ?',
    [delDateTime, memoId],
  );
}

/* memoOrder更新 */
Future<void> updateMemoOrder(int orderId, String memoId) async {
  final db = await database;

  await db.execute(
    'REPLACE INTO memoOrder(id, memoId) VALUES(?, ?);',
    [orderId, memoId,],
  );
}

/* 論理削除されたメモプレビューを取得 */
Future<List<Memo?>> getGarbageMemoPreview({String orderby='desc'}) async {
  final db = await database;
  // DBからデータリストを取得
  final List<Map<String, dynamic>> maps = await db.rawQuery(
    '''
    SELECT id AS memoId, SUBSTR(memo, 1, 150) AS memoPreview, backColor 
    FROM memo 
    WHERE id NOT IN ( SELECT memoId FROM memoOrder ) 
    ORDER BY id $orderby
    ''',
  );

  /** 空白データをnullで埋めつつ、プレビューデータを配列に */
  final previewList = <Memo?>[];  // プレビューデータ配列
  for (var i = 0; i < maps.length; i++) {
    // DBから取得したデータを配列に追加
    previewList.add(Memo(
      orderId: -1,
      memoId: maps[i]['memoId'] as String,
      memoPreview: maps[i]['memoPreview'] as String?,
      backColor: maps[i]['backColor'] as int,
    ),);
  }

  return previewList;
}

/* 論理削除されているメモデータを復元 */
Future<void> repairMemo(String memoId) async {
  final db = await database;

  /** orderIdを取得 */
  final orderId = await getNewOrderId();

  /** memoOrderテーブルに登録 */
  await db.rawInsert(
    'INSERT INTO memoOrder(id, memoId) VALUES (?, ?)',
    [orderId, memoId],
  );
  /** memoのdelDateTimeをnullで更新 */
  await db.rawUpdate(
    'UPDATE memo SET delDateTime = ? WHERE id = ?',
    [null, memoId],
  );
}

/* 論理削除されているメモデータを完全削除 */
Future<void> deleteForeverMemo(String memoId) async {
  final db = await database;
  // memoのレコードを削除しメモを完全削除する。
  await db.delete('memo', where: 'id NOT IN ( SELECT memoId FROM memoOrder ) AND id = ?', whereArgs: [memoId]);
}

/* 一定期間内の論理削除されたメモを削除 */
Future<void> deleteGarbageMemo({DateTime? staDateTime, DateTime? endDateTime}) async {
  final db = await database;
  // 削除する期間のmemoIdを加工
  final staDt =  DateFormat('yyyyMMdd-HHmmss').format(staDateTime ?? DateTime(1900));
  final endDt =  DateFormat('yyyyMMdd-HHmmss').format(endDateTime ?? DateTime.now());
  // 一定期間のメモを完全削除
  await db.rawDelete(
    '''
    DELETE 
    FROM memo 
    WHERE id NOT IN ( SELECT memoId FROM memoOrder ) 
    AND delDateTime >= ? AND delDateTime <= ?
    ''',
    [staDt, endDt],
  );
}
