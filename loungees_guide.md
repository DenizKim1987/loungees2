# Loungees 프로젝트 개발 가이드

## 📋 프로젝트 개요

- **프로젝트명**: Loungees
- **구조**: 모노레포 (Monorepo)
- **아키텍처**: 클린 아키텍처 (Clean Architecture)
- **플랫폼**: Flutter (Multi-platform)

## 🏗️ 모노레포 구조

```
loungees/
├── apps/                          # 애플리케이션들
│   ├── loungees_seller/          # 판매자 앱
│   ├── loungees_customer/        # 고객 앱 (예정)
│   └── loungees_admin/           # 관리자 앱 (예정)
├── packages/                      # 공유 패키지들
│   ├── core/                     # 핵심 공통 기능
│   ├── shared/                   # 공유 컴포넌트
│   └── domain/                   # 도메인 로직
├── functions/                    # Firebase Functions
└── docs/                         # 문서
```

## 🎯 클린 아키텍처 원칙

### 1. 의존성 규칙 (Dependency Rule)

- **외부 레이어는 내부 레이어를 알 수 없음**
- **내부 레이어는 외부 레이어에 의존하지 않음**
- **의존성은 항상 안쪽으로만 향함**

### 2. 레이어 구조

```
Presentation Layer (UI)     ← 사용자 인터페이스
    ↓
Application Layer           ← 유스케이스, 상태관리
    ↓
Domain Layer               ← 비즈니스 로직, 엔티티
    ↓
Infrastructure Layer       ← 데이터베이스, API, 외부 서비스
```

## 📁 폴더 구조 가이드

### 각 앱 내부 구조 (`apps/loungees_seller/lib/`)

```
lib/
├── main.dart                    # 앱 진입점
├── app/                        # 앱 설정
│   ├── app.dart
│   ├── routes/
│   └── theme/
├── core/                       # 핵심 기능
│   ├── constants/
│   ├── errors/
│   ├── network/
│   ├── utils/
│   └── extensions/
├── features/                   # 기능별 모듈
│   └── [feature_name]/
│       ├── data/
│       │   ├── datasources/
│       │   ├── models/
│       │   └── repositories/
│       ├── domain/
│       │   ├── entities/
│       │   ├── repositories/
│       │   └── usecases/
│       └── presentation/
│           ├── pages/
│           ├── widgets/
│           └── providers/
└── shared/                     # 공유 컴포넌트
    ├── widgets/
    ├── utils/
    └── constants/
```

## 🔧 개발 규칙

### 1. 네이밍 컨벤션

- **파일명**: snake_case (예: `user_repository.dart`)
- **클래스명**: PascalCase (예: `UserRepository`)
- **변수/함수명**: camelCase (예: `getUserData`)
- **상수**: SCREAMING_SNAKE_CASE (예: `API_BASE_URL`)

### 2. 폴더 구조 규칙

- **기능별로 폴더 분리**: 각 기능은 독립적인 모듈로 구성
- **레이어별 분리**: data, domain, presentation 레이어 명확히 구분
- **공통 기능은 shared 폴더에**: 재사용 가능한 컴포넌트는 shared에 배치

### 3. 의존성 주입 규칙

- **GetIt 또는 Provider 사용**: 의존성 주입 컨테이너 활용
- **인터페이스 기반**: 구현체가 아닌 인터페이스에 의존
- **생성자 주입**: 생성자를 통한 의존성 주입 선호

## 📦 패키지 구조

### 공유 패키지 (`packages/`)

```
packages/
├── core/                       # 핵심 공통 기능
│   ├── lib/
│   │   ├── constants/
│   │   ├── errors/
│   │   ├── network/
│   │   └── utils/
│   └── pubspec.yaml
├── shared/                     # 공유 UI 컴포넌트
│   ├── lib/
│   │   ├── widgets/
│   │   ├── themes/
│   │   └── utils/
│   └── pubspec.yaml
└── domain/                     # 도메인 로직
    ├── lib/
    │   ├── entities/
    │   ├── repositories/
    │   └── usecases/
    └── pubspec.yaml
```

## 🚀 개발 워크플로우

### 1. 새 기능 개발 시

1. **기능 분석**: 어떤 도메인에 속하는지 파악
2. **폴더 생성**: `features/[feature_name]/` 구조 생성
3. **레이어별 구현**:
   - Domain Layer: Entity, Repository Interface, UseCase
   - Data Layer: Model, Repository Implementation, DataSource
   - Presentation Layer: Page, Widget, Provider/Bloc
4. **의존성 주입**: GetIt에 등록
5. **테스트 작성**: 각 레이어별 테스트

### 2. 공통 기능 개발 시

1. **패키지 생성**: `packages/[package_name]/` 생성
2. **pubspec.yaml 설정**: 의존성 정의
3. **기능 구현**: 패키지 내부에서 기능 개발
4. **앱에서 사용**: 앱의 pubspec.yaml에 패키지 추가

## 📝 코딩 스타일

### 1. Dart/Flutter 스타일

- **공식 스타일 가이드 준수**: `dart format` 사용
- **Lint 규칙 준수**: `analysis_options.yaml` 설정
- **주석 작성**: 복잡한 로직에는 주석 필수

### 2. 아키텍처 패턴

- **Repository Pattern**: 데이터 접근 추상화
- **UseCase Pattern**: 비즈니스 로직 캡슐화
- **Provider/Bloc Pattern**: 상태 관리

### 3. 에러 처리

- **Custom Exception**: 도메인별 예외 클래스 생성
- **Result Pattern**: 성공/실패 결과 처리
- **로깅**: 적절한 로그 레벨 사용

## 🧪 테스트 전략

### 1. 테스트 구조

```
test/
├── unit/                       # 단위 테스트
│   ├── domain/
│   ├── data/
│   └── presentation/
├── widget/                     # 위젯 테스트
└── integration/                # 통합 테스트
```

### 2. 테스트 커버리지

- **최소 80% 커버리지**: 핵심 비즈니스 로직
- **UseCase 테스트**: 모든 유스케이스 테스트 필수
- **Repository 테스트**: 데이터 접근 로직 테스트

## 🔄 상태 관리

### 1. 상태 관리 패턴

- **Provider**: 간단한 상태 관리
- **Bloc/Cubit**: 복잡한 상태 관리
- **Riverpod**: 타입 안전한 상태 관리

### 2. 상태 구조

```dart
// 상태 클래스 예시
@freezed
class UserState with _$UserState {
  const factory UserState.initial() = _Initial;
  const factory UserState.loading() = _Loading;
  const factory UserState.loaded(User user) = _Loaded;
  const factory UserState.error(String message) = _Error;
}
```

## 🌐 네트워킹

### 1. API 클라이언트

- **Dio 사용**: HTTP 클라이언트
- **인터셉터**: 로깅, 인증, 에러 처리
- **모델 변환**: JSON ↔ Dart 객체 변환

### 2. API 구조

```dart
// API 서비스 예시
abstract class UserApiService {
  Future<UserModel> getUser(String id);
  Future<List<UserModel>> getUsers();
  Future<UserModel> createUser(CreateUserRequest request);
}
```

## 📱 UI/UX 가이드

### 1. 디자인 시스템

- **Material Design 3**: 최신 머티리얼 디자인 적용
- **커스텀 테마**: 브랜드 컬러 적용
- **반응형 디자인**: 다양한 화면 크기 대응

### 2. 컴포넌트 구조

- **재사용 가능한 위젯**: shared 패키지에 배치
- **컴포지션**: 작은 위젯들의 조합
- **테마 일관성**: 전체 앱의 일관된 디자인

## 🔒 보안 가이드

### 1. 데이터 보안

- **민감한 데이터 암호화**: 로컬 저장 시 암호화
- **API 키 보호**: 환경 변수 사용
- **인증 토큰 관리**: 안전한 토큰 저장

### 2. 코드 보안

- **민감한 정보 제외**: 하드코딩 금지
- **입력 검증**: 사용자 입력 검증
- **에러 메시지**: 민감한 정보 노출 방지

## 📊 성능 최적화

### 1. 앱 성능

- **이미지 최적화**: 적절한 이미지 포맷 사용
- **메모리 관리**: 불필요한 객체 생성 방지
- **빌드 최적화**: 릴리즈 빌드 최적화

### 2. 네트워크 성능

- **캐싱**: 적절한 캐싱 전략
- **배치 요청**: 여러 요청 배치 처리
- **오프라인 지원**: 네트워크 없이도 동작

## 🚀 배포 가이드

### 1. 빌드 설정

- **환경별 설정**: dev, staging, production
- **코드 사이닝**: 앱 서명 설정
- **번들 최적화**: 앱 크기 최적화

### 2. CI/CD

- **자동화된 테스트**: PR 시 자동 테스트
- **자동 배포**: 성공 시 자동 배포
- **롤백 전략**: 문제 발생 시 롤백

## 📚 참고 자료

### 1. Flutter 관련

- [Flutter 공식 문서](https://docs.flutter.dev/)
- [Dart 언어 가이드](https://dart.dev/guides)
- [Flutter 아키텍처 샘플](https://github.com/brianegan/flutter_architecture_samples)

### 2. 클린 아키텍처

- [Clean Architecture by Robert C. Martin](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Flutter Clean Architecture](https://github.com/ResoCoder/flutter-tdd-clean-architecture-course)

### 3. 모노레포

- [Melos](https://melos.invertase.dev/) - Dart/Flutter 모노레포 도구
- [Monorepo Best Practices](https://monorepo.tools/)

---

## ⚠️ 중요 사항

1. **이 가이드를 반드시 준수**하여 개발 진행
2. **새로운 기능 개발 전** 이 가이드 재검토
3. **코드 리뷰 시** 아키텍처 원칙 준수 여부 확인
4. **문서 업데이트**: 새로운 패턴이나 규칙 추가 시 이 가이드 업데이트

**마지막 업데이트**: 2024년 12월
