[English](README.md)

# my_api

[API 문서](https://rivmt.github.io/my_api/)

## 소개

`my_api`는 MySuite 앱에서 공통으로 사용하는 Flutter 패키지입니다. 여러 앱의 API 엔드포인트를 함께 제공하는 별도 백엔드 프로젝트 `kyro`와 통신하는 데 필요한 클라이언트 모델, 인증, API 접근, 상태 관리, 재사용 가능한 UI 구성요소를 제공합니다.

현재 패키지에는 공통 앱 기반 기능과 MyFinance에서 사용하는 개인 재무 기능이 포함되어 있습니다.

> 이 저장소는 백엔드 서버가 아니라 클라이언트 라이브러리입니다. 인증된 API를 사용하려면 실행 중인 `kyro` 인스턴스와 OIDC(OpenID Connect) 공급자가 필요합니다.

## 기능

- **REST API 클라이언트**: 싱글턴 `ApiClient`를 통해 타입이 지정된 생성, 조회, 수정, 삭제, 통계, 스트리밍 검색 작업을 제공합니다.
- **OIDC 인증**: 공개 클라이언트를 위한 PKCE 기반 Authorization Code Flow 로그인과 로그아웃, 토큰 저장, API 요청의 Bearer 토큰 설정을 처리합니다.
- **재무 모델**: 계좌, 결제 수단, 거래, 카테고리, 통화, 환경 설정 모델을 제공합니다.
- **Riverpod 상태 관리**: API 기반 모델을 불러오고 수정하거나 검색하고 값을 계산하는 notifier와 provider를 제공합니다.
- **쿼리 지원**: `ApiQuery`를 통한 정렬, 날짜·값 범위, 필터링, 문자열 검색을 지원합니다.
- **재사용 가능한 UI**: 테마, 반응형 화면 설계, 카드, 대화상자, 모달, 차트, 날짜 컨트롤, 로딩 상태, 재무 전용 위젯을 제공합니다.
- **내비게이션 유틸리티**: Flutter 앱에서 재사용할 수 있는 route path, parser, router delegate 기반 클래스를 제공합니다.
- **데이터 유틸리티**: 모델 직렬화와 CSV 변환에 사용할 수 있는 `DataFrame`을 제공합니다.
- **확장성**: 추가 모델 타입을 사용자 정의 엔드포인트와 역직렬화 로직에 연결하는 확장 훅을 제공합니다.

주요 공개 라이브러리는 다음과 같습니다.

| 라이브러리 | 용도 |
| --- | --- |
| `package:my_api/core.dart` | API 클라이언트, 공통 모델, notifier, 내비게이션, 유틸리티, 테마, 공통 위젯 |
| `package:my_api/finance.dart` | 재무 모델과 재무 전용 위젯 |
| `package:my_api/provider.dart` | 공통 및 재무 Riverpod provider |

## 설정 방법

### 1. 개발 환경 준비

다음 항목이 필요합니다.

- Dart `>=2.18.6 <3.0.0`과 호환되는 Flutter SDK
- 필요한 앱 엔드포인트를 제공하는 `kyro` 백엔드
- OIDC 공급자와 등록된 클라이언트

저장소를 받은 뒤 의존성을 설치합니다.

```bash
flutter pub get
```

다른 Flutter 프로젝트에서 이 패키지를 사용하려면 Git 의존성을 추가합니다.

```yaml
dependencies:
  my_api:
    git:
      url: https://github.com/RivMt/my_api
      ref: master
```

로컬에서 함께 개발할 때는 path 의존성을 사용합니다.

```yaml
dependency_overrides:
  my_api:
    path: ../my_api
```

### 2. API 클라이언트 초기화

Flutter binding을 초기화한 뒤 앱을 시작하기 전에 `ApiClient().init(...)`을 호출합니다.

```dart
import 'package:flutter/widgets.dart';
import 'package:my_api/core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await ApiClient().init({
    'apiScheme': 'https',
    'apiUri': 'api.example.com',
    'authUri': 'https://auth.example.com/realms/mysuite',
    'clientId': 'my-app',
    'redirectUri': 'https://app.example.com/redirect.html',
    'mode': 'production',
  });

  runApp(const MyApp());
}
```

| 키 | 설명 |
| --- | --- |
| `apiScheme` | `kyro` 요청에 사용할 스킴입니다. 생략하면 `https`를 사용합니다. |
| `apiUri` | `kyro`의 호스트와 선택적 포트입니다. 현재 구현은 스킴 없이 `host` 또는 `host:port` 형식을 사용합니다. 예: `api.example.com`, `localhost:8080` |
| `authUri` | OpenID 설정을 찾는 데 사용하는 OIDC 공급자 또는 realm의 전체 URI입니다. |
| `clientId` | OIDC 공급자에 등록한 클라이언트 ID입니다. |
| `redirectUri` | 로그인 redirect URI입니다. OIDC 공급자에 등록한 값과 정확히 같아야 합니다. |
| `mode` | 애플리케이션 모드입니다: `production`, `dev`, `demo`. |

애플리케이션을 공개 OIDC 클라이언트로 등록하고 토큰 엔드포인트 인증 방식을 `none`으로 설정한 뒤, `S256` challenge 방식을 사용하는 PKCE를 필수로 설정하세요. `my_api`는 client secret을 저장하거나 전송하지 않습니다.

### 3. 인증 및 데이터 접근

앱에서 필요한 공개 라이브러리만 import합니다.

```dart
import 'package:my_api/core.dart';
import 'package:my_api/finance.dart';
import 'package:my_api/provider.dart' as provider;
```

공유 클라이언트를 통해 인증하고 지원되는 모델에 타입 기반 작업을 수행합니다.

```dart
final client = ApiClient();

final user = await client.login();
final accounts = await client.read<Account>({
  ModelKeys.keyDeleted: false,
});

if (accounts.result == ApiResponseResult.success) {
  for (final account in accounts.data) {
    Log.i('Example', account.name);
  }
}

await client.logout();
```

내장 모델 엔드포인트는 다음 `kyro` 경로에 연결됩니다.

- `api/core/preferences`
- `api/finance/accounts`
- `api/finance/payments`
- `api/finance/transactions`
- `api/finance/categories`
- `api/finance/currencies`

추가 모델 타입을 지원하려면 타입 기반 요청을 보내기 전에 `ApiClient.handleExtendedEndpoint`와 `ApiClient.extendCast`를 설정합니다.

### 4. 검사 및 테스트

다음 명령으로 패키지를 분석하고 모델 테스트를 실행합니다.

```bash
flutter analyze
flutter test
```

전체 공개 클래스와 메서드 레퍼런스는 생성된 [API 문서](https://rivmt.github.io/my_api/)에서 확인할 수 있습니다.
