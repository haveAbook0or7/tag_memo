
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tag_memo/data/backup/backup_const.dart';
import 'package:tag_memo/data/sqlite/memo.dart';
import 'package:tag_memo/data/sqlite/sqlite.dart';


Future<int> backupDatas() async {
  final previewList = await getMemoPreview();
  final memoMapsList = <Map<String, dynamic>?>[];

  /** 全メモデータを取得 */
  for (var i = 0; i < previewList.length; i++) {
    if(previewList[i] == null){
      memoMapsList.add(null);
    }else{
      final tmp = await getMemo(previewList[i]!.memoId);
      memoMapsList.add(tmp.toMap());
    }
  }
  /** バックアップ処理 */
  final header = { // ヘッダ
    'Authorization': AUTH_STR,
    'content-type': 'application/json',
  };
  final reqBody = { // リクエストボディ
    'data': memoMapsList,
  };
  // POSTリクエスト
  final resp = await http.post(Uri.parse('$URL_BACKUP_LAMBDA/backup'),
    headers: header,
    body: json.encode(reqBody),
  );

  return resp.statusCode;
}

Future<int> restoreDatas() async {
  /** リストア処理 */
  final header = { // ヘッダ
    'Authorization': AUTH_STR,
  };
  // GETリクエスト
  final resp = await http.get(Uri.parse('$URL_BACKUP_LAMBDA/restore'),
    headers: header,
  );
  final resBody = json.decode(resp.body);
  // ignore: avoid_dynamic_calls
  final backupMemoList = resBody['data'] as List<dynamic>;

  /**  リクエストが失敗した場合、この後の処理をキャンセル */
  if(resp.statusCode != 200) { return resp.statusCode; }

  /** 全メモデータを置き換え */
  // 全メモデータを論理削除
  final previewList = await getMemoPreview();
  for (var i = 0; i < previewList.length; i++) {
    if(previewList[i] == null){
      continue;
    }
    await deleteMemoOrder(previewList[i]!.memoId);
  }
  // メモデータを順に作成
  for (var i = 0; i < backupMemoList.length; i++) {
    if(backupMemoList[i] == null){
      continue;
    }
    final memo = Memo(
      orderId: backupMemoList[i]!['orderId']! as int,
      memoId: backupMemoList[i]!['memoId'] as String,
      memoPreview: backupMemoList[i]!['memoPreview'] as String,
      memo: backupMemoList[i]!['memo'] as String,
      backColor: backupMemoList[i]!['backColor'] as int,
    );
    await insertMemo(memo);
  }

  return resp.statusCode;
}
