import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:tag_memo/data/backup/backup_const.dart';
import 'package:tag_memo/data/sqlite/memo.dart';
import 'package:tag_memo/data/sqlite/sqlite.dart';
import 'package:tag_memo/env/env.dart';

Map<String,dynamic> aws4authRequest(String url, String httpMethod, {Map<String,String>? orginHeaders, Map<String,dynamic>? queryString, Map<String,dynamic>? body}){
  orginHeaders = orginHeaders ?? {};
  queryString  = queryString  ?? {};
  body         = body         ?? {};
  /** 手順 1: 正規リクエストを作成する ******************************************/
  // ホスト名
  final host = url.split('/')[2];
  // リクエストのパス
  final canonicalUri = '/${url.split('/').skip(3).join('/')}';
  // 日時(yyyymmddThhmmssZ, yyyymmdd)
  final today = DateTime.now().toUtc();
  final yyyymmddThhmmssZ = '${DateFormat('yyyyMMddThhmmss').format(today)}Z';
  final yyyymmdd = DateFormat('yyyyMMdd').format(today);
  debugPrint(yyyymmddThhmmssZ);
  // クエリ文字列(キー名のアルファベット順にソート)
  final tmpQueryString = <String>[];
  List<String>.from(queryString.keys)
  ..sort((a, b) => a.compareTo(b))
  ..forEach((key) => tmpQueryString.add('$key=${queryString?[key]}'));
  final canonicalQueryString = tmpQueryString.join('&');
  // ペイロード
  final payload = httpMethod == 'GET' ? '' : json.encode(body);
  // ペイロードをsha256で16進形式ハッシュにしたもの
  final hashedPayload = sha256.convert(utf8.encode(payload));
  // リクエストヘッダ名と値のリスト([小文字のヘッダ名]:[値]\n)
  final aws4authHerders = {
    'host': host,
    'x-amz-content-sha256': hashedPayload.toString(),
    'x-amz-date': yyyymmddThhmmssZ,
  };
  final tmpHeaderKeys = <String>[];
  var canonicalHeaders = '';
  List<String>.from(aws4authHerders.keys)
  ..sort((a, b) => a.compareTo(b))
  ..forEach((key) {
    tmpHeaderKeys.add(key);
    canonicalHeaders += '${key.toLowerCase()}:${aws4authHerders[key]}\n';
  });
  // リクエストヘッダ名のリスト(アルファベット順にソート)
  final signedHeaders = tmpHeaderKeys.join(';');

  /** 正規リクエスト(上で生成した要素を\nで連結) */
  final canonicalRequest = '$httpMethod\n$canonicalUri\n$canonicalQueryString\n$canonicalHeaders\n$signedHeaders\n$hashedPayload';
  debugPrint('canonicalRequest: $canonicalRequest');

  /** 手順 2: 正規リクエストのハッシュを作成する *********************************/
  /** 正規リクエストをsha256で16進形式ハッシュにしたもの */
  final hashedCanonicalRequest = sha256.convert(utf8.encode(canonicalRequest));
  debugPrint('hashedCanonicalRequest: $hashedCanonicalRequest');

  /** 手順 3: 署名文字列を作成する **********************************************/
  // アルゴリズム
  const algorithm = 'AWS4-HMAC-SHA256';
  // リクエスト日時(yyyymmddThhmmssZ)
  final requestDateTime = yyyymmddThhmmssZ;
  // 認証情報のスコープ
  final credentialScope = '$yyyymmdd/$RESION/$SERVICE/aws4_request';

  /** 署名文字列 */
  final stringToSign = '$algorithm\n$requestDateTime\n$credentialScope\n$hashedCanonicalRequest';
  debugPrint('stringToSign: $stringToSign');

  /** 手順 4: 署名を計算する */
  // AWS4[IAMユーザのシークレットキー]をキー、[リクエスト日時(yyyymmdd)]を値、ハッシュ形式をsha256として、HMACでハッシュ(bytes)にする
  final dateKey = Hmac(sha256, utf8.encode('AWS4${Env.SECRET_KEY}')).convert(utf8.encode(yyyymmdd)).bytes;
  // 上のハッシュ(bytes)をキー、[APIリクエストするサービスのリージョン]を値、ハッシュ形式をsha256として、HMACでハッシュ(bytes)にする
  final dateRegionKey = Hmac(sha256, dateKey).convert(utf8.encode(RESION)).bytes;
  // 上のハッシュ(bytes)をキー、[APIリクエストするサービス]を値、ハッシュ形式をsha256として、HMACでハッシュ(bytes)にする
  final dateRegionServiceKey = Hmac(sha256, dateRegionKey).convert(utf8.encode(SERVICE)).bytes;
  // 上のハッシュ(bytes)をキー、"aws4_request"を値、ハッシュ形式をsha256として、HMACでハッシュ(bytes)にする
  final signingKey = Hmac(sha256, dateRegionServiceKey).convert(utf8.encode('aws4_request')).bytes;

  /** 署名 */
  final signature = Hmac(sha256, signingKey).convert(utf8.encode(stringToSign));
  debugPrint('signature: $signature');

  final authorization = '$algorithm Credential=${Env.ACCESS_KEY}/$credentialScope,SignedHeaders=$signedHeaders,Signature=$signature';
  debugPrint('authorization: $authorization');
  orginHeaders..addAll({ 'authorization': authorization})
  ..addAll(aws4authHerders);

  return {
    'url': canonicalQueryString.isEmpty ? url : '$url?$canonicalQueryString',
    'headers': orginHeaders,
    'body': payload,
  };
}

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
  final reqData = aws4authRequest('$HOST_URL/backup', 'POST', 
    orginHeaders: {
      'content-type': 'application/json',
      'userid': Env.USER_ID,
    },
    body: {
    'data': memoMapsList,
    },
  );
  // POSTリクエスト
  final resp = await http.post(Uri.parse(reqData['url'] as String),
    headers: reqData['headers'] as Map<String, String>,
    body: reqData['body'] as String,
  );

  return resp.statusCode;
}

Future<int> restoreDatas() async {
  /** リストア処理 */
  final reqData = aws4authRequest('$HOST_URL/restore', 'GET', 
    orginHeaders: {
      'userid': Env.USER_ID,
    },
  );
  // GETリクエスト
  final resp = await http.get(Uri.parse(reqData['url'] as String),
    headers: reqData['headers'] as Map<String, String>,
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
