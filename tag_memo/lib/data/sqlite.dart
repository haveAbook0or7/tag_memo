import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'package:tag_memo/data/memo.dart';


final Future<Database> database = getDatabasesPath().then((String path) {

  return openDatabase(
    join(path, 'money_database.db'),
    onCreate: (Database db, int version) async {
      await db.execute(
        '''
        CREATE TABLE memo(
          id INTEGER PRIMARY KEY AUTOINCREMENT, 
          memo TEXT, 
          backColor INTEGER
        )
        '''
      );
      await db.execute(
        '''
        CREATE TABLE memoOrder(
          id INTEGER PRIMARY KEY, 
          memoId INTEGER, 
          FOREIGN KEY(memoId) REFERENCES memo(id)
        )
        '''
      );
      // テスト用
      await db.execute('INSERT INTO memo (memo, backColor) VALUES ("サンプルサンプルサンプルサンプル\nサンプル", 500)');
      await db.execute('INSERT INTO memoOrder (memoId) VALUES (1)');

    },
    version: 1,
  );

});

/* メモプレビュー取得用 */
Future<List<Memo?>> getMemoPreview() async {
  final db = await database;
  // リストを取得
  final List<Map<String, dynamic>> maps = await db.rawQuery(
    '''
    SELECT mO.id, mO.memoId, SUBSTR(m.memo, 1, 150) AS memoPreview, m.backColor 
    FROM memoOrder AS mO 
    LEFT OUTER JOIN memo AS m 
    ON mO.memoId = m.id
    '''
  );

  final list = <Memo?>[];
  for (var i = 0; i < maps.length; i++) {
    if (maps[i]['memoId'] != 0) {
      list.add(Memo(
        orderId: maps[i]['id'] as int,
        memoId: maps[i]['memoId'] as int,
        memoPreview: maps[i]['memoPreview'] as String?,
        backColor: maps[i]['backColor'] as int,
      ),);

    } else {
      // 空白はnull
      list.add(null);
    }
  }

  return list;
}

/* メモ取得用 */
Future<Memo> getMemo(int memoId) async {
  final db = await database;
  // リストを取得
  final List<Map<String, dynamic>> maps = await db.rawQuery(
    '''
    SELECT mO.id, mO.memoId, m.memo, m.backColor 
    FROM memoOrder AS mO 
    LEFT OUTER JOIN memo AS m 
    ON mO.memoId = m.id 
    WHERE mO.memoId = ?
    ''',
    [memoId],
  );

  final memo = Memo(
    orderId: maps[0]['id'] as int,
    memoId: maps[0]['memoId'] as int,
    memo: maps[0]['memo'] as String?,
    backColor: maps[0]['backColor'] as int,
  );

  return memo;
}

/* メモ新規作成 */
Future<void> insertMemo(Memo memo) async {
  final db = await database;

  // memoテーブルに登録
  await db.rawInsert(
    'INSERT INTO memo(memo, backColor) VALUES (?, ?)',
    [memo.memo, memo.backColor],
  );

  /* 先ほど登録したメモのIDを取得 */
  final memoId = await getMaxMemoId();

  /* memoOrderテーブルの最後に登録 */
  await db.rawInsert(
    'INSERT INTO memoOrder(memoId) VALUES (?)',
    [memoId],
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

/* 新規作成したメモIDを取得(memo　の主キーの一番大きい数字を取得) */
Future<int> getMaxMemoId() async {
  final db = await database;

  // リストを取得
  final List<Map<String, dynamic>> maps = await db.rawQuery('SELECT MAX(id) FROM memo');
  final memoId = maps[0]['MAX(id)'] as int;

  return memoId;
}

/* memoOrder 主キー昇順　に並んだ memoId のリスト */
Future<List<int>> getMemoIds({String orderBy = 'asc'}) async {
  final db = await database;

  // リストを取得
  final List<Map<String, dynamic>> maps = await db.rawQuery(
    'SELECT memoId FROM memoOrder ORDER BY id ?',
    [orderBy],
  );

  final list = <int>[];
  for (var i = 0; i < maps.length; i++) {
    list.add(maps[i]['memoId'] as int);

  }

  return list;
}

/* メモの削除用 */
Future<void> deleteMemo(int memoId) async {
  // 旧付箋リストのメモIDリストを取得
  final memoIds = await getMemoIds();

  // 削除するメモを取り除く
  final index = memoIds.indexOf(memoId);
  memoIds[index] = 0;

  // 新しい memoOrder を登録
  await renewMemoOrder(memoIds);

  // メモ本体を削除
  final db = await database;
  await db.delete('memo', where: 'id = ?', whereArgs: [memoId]);

}

/* メモの並び替え */
Future<List<Memo?>> sortMemoOrder(List<int> memoIds) async {
  // 新しい memoOrder を登録
  await renewMemoOrder(memoIds);

  // 新しい付箋リストを取得
  final list = await getMemoPreview();

  return list;
}

/* 新しい順番のmemoOrderを登録 */
Future<void> renewMemoOrder(List<int> memoIds) async {
  // 全削除
  await deleteMemoOrders();

  // memoIdsを順番に登録
  final db = await database;

  for (var i = 0; i < memoIds.length; i++) {
    await db.rawInsert(
      'INSERT INTO memoOrder (memoId) VALUES (?)',
      [memoIds[i]],
    );

  }

}

/* memoOrder全削除用 */
Future<void> deleteMemoOrders() async {
  final db = await database;
  await db.delete('memoOrder');
}
