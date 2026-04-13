# Modus

<p align="center">
  <img src="assets/images/modus_text_logo.png" alt="Modus" width="220" />
</p>

<p align="center">
  학생 모둠 활동을 더 안전하고 균형 있게 만드는 AI 협업 도우미
</p>

<p align="center">
  <strong>Flutter</strong> · <strong>Clean Architecture</strong> · <strong>Socket.IO Chat</strong> · <strong>AI Facilitation</strong>
</p>

---

## 1. 서비스 한 줄 소개

Modus는 학생들이 모둠 과제와 토론을 진행할 때, AI가 대화를 검열하거나 정답을 대신 내리는 대신 표현을 부드럽게 다듬고, 참여가 적은 흐름을 자연스럽게 열어주며, 협업 기여를 역할 기반으로 분석하는 학습 협업 플랫폼입니다.

## 2. 해결하려는 문제

모둠 활동은 실제 수업에서 자주 사용되지만, 다음 문제가 반복됩니다.

| 문제 | 기존 방식의 한계 | Modus의 접근 |
| --- | --- | --- |
| 공격적이거나 거친 표현 | 교사가 뒤늦게 확인하거나 학생 간 갈등으로 번짐 | 전송 직전에 AI가 부드러운 표현을 제안 |
| 참여 불균형 | 말이 많은 학생 위주로 논의가 흘러감 | 일정 메시지마다 흐름을 판단하고 필요할 때만 개입 |
| 익명성과 개성의 균형 | 실명은 부담스럽고 완전 익명은 책임감이 낮아짐 | 설문 기반 한국어 닉네임으로 안전한 정체성 제공 |
| 기여도 판단의 왜곡 | 메시지 수가 많으면 기여도가 높다고 오해하기 쉬움 | 질문, 요약, 자료 제안, 갈등 완화 등 역할 중심 분석 |

## 3. 핵심 가치

Modus의 AI는 평가자가 아니라 협업 보조자입니다.

- 학생을 공개적으로 지적하지 않습니다.
- 점수나 낙인보다 역할과 맥락을 우선합니다.
- 대화를 대신 주도하지 않고, 필요한 순간에만 짧게 돕습니다.
- 정답을 대필하지 않고, 생각을 확장하는 질문을 제안합니다.
- 민감한 개인정보, 성별, 외모, 능력 낙인 표현을 피합니다.

## 4. 주요 기능

### 4.1 인증 및 수업 참여

- 로그인, 회원가입, 이메일 인증 UI 흐름
- 학생 수업 목록 조회
- 수업 코드 기반 수업 참여
- 수업 상세에서 모둠 배정 여부에 따른 화면 분기

### 4.2 설문 기반 협업 성향 입력

- 모둠 활동 전 협업 스타일, 의사소통 방식, 강점, 선호 분위기 입력
- 이후 AI 닉네임 생성 및 협업 맥락 분석에 활용 가능한 구조

### 4.3 모둠 닉네임 조회

- `GET /groups/{groupId}/nickname`
- 현재 사용자의 모둠 닉네임과 생성 이유를 조회
- 모둠 상세 진입 시 닉네임 안내 모달 표시

예시:

```json
{
  "nickname": "차분한 설계자",
  "reason": "차분하게 정리하고 구조를 잡는 성향을 반영한 닉네임이에요."
}
```

### 4.4 실시간 모둠 채팅

- Socket.IO 기반 그룹 채팅
- 입장 시 기존 채팅 히스토리 수신
- 모둠 상세 조회 후 가장 최근 채팅이 보이도록 자동 스크롤
- 메시지 전송 후 최신 메시지 위치로 자동 이동
- 본인 메시지 수정 및 삭제 UI

### 4.5 채팅 전송 전 AI 문장 조언

- `POST /chat/message-advice`
- 메시지를 전송하기 직전에 표현 위험도를 검사
- 모든 메시지를 매번 검사하지 않고, 위험 키워드와 문장 길이를 기준으로 필요한 경우만 호출
- 욕설 등 강한 표현은 서버가 `shouldBlock: false`를 내려도 원문 전송을 막고 수정 유도
- AI 응답의 `warning`과 `suggestedRewrite`를 흰색 모달로 명확하게 표시

예시 응답:

```json
{
  "riskLevel": "medium",
  "shouldBlock": false,
  "warning": "욕설이 포함되어 주의가 필요합니다",
  "suggestedRewrite": "조금 답답한 부분이 있어요"
}
```

### 4.6 그룹 대화 AI 개입 조언

- `POST /chat/intervention-advice`
- 메시지 10개 단위로 대화 흐름을 판단
- 10개마다 무조건 개입하지 않고, `interventionNeeded`가 true일 때만 모달 표시
- 특정 학생을 지목하지 않고 전체 그룹을 향한 중립적인 문장을 추천
- 수동으로도 `AI 조언` 버튼을 눌러 대화 흐름 제안을 받을 수 있음

예시 응답:

```json
{
  "interventionNeeded": true,
  "interventionType": "participation",
  "reason": "대화의 존중을 지키며 모두의 참여를 촉진 필요",
  "suggestedMessage": "모두의 아이디어를 한마디씩 공유해볼까요"
}
```

### 4.7 역할 기반 기여도 분석

- `POST /chat/contribution-analysis`
- 단순 메시지 개수가 아닌 역할 기반으로 기여 유형을 분석
- 현재 클라이언트는 API, 도메인, 데이터 매핑까지 연결
- 학생 화면에는 점수처럼 보이는 기여도 UI를 노출하지 않도록 조정
- 교사 또는 운영자용 리포트 확장에 적합한 구조

분석 축:

- 논의 시작
- 질문 제기
- 답변 제공
- 자료 제안
- 요약 및 정리
- 갈등 완화
- 실행 기여
- 의사결정 기여

## 5. AI 개입 설계 원칙

Modus의 AI 기능은 다음 철학을 기준으로 설계했습니다.

| 해야 하는 역할 | 하지 않아야 하는 역할 |
| --- | --- |
| 협업 도우미 | 정답 대필 |
| 대화 촉진자 | 학생 평가 확정 |
| 표현 완화 도우미 | 사용자 낙인찍기 |
| 사고 확장 보조자 | 공개적으로 비교하거나 지적하기 |
| 정리 및 요약 보조자 | 대화 주도권 빼앗기 |

특히 그룹 개입 조언은 “OO님이 참여가 부족합니다”처럼 특정 학생을 지목하지 않습니다. 대신 “다른 관점도 자유롭게 말해볼까요”처럼 전체 그룹을 향한 중립 문장으로 대화의 문을 엽니다.

## 6. 데모 시나리오

심사 시연에서는 아래 흐름으로 보는 것을 권장합니다.

1. 로그인 또는 회원가입 화면에서 서비스 진입
2. 설문 화면에서 협업 성향 입력
3. 수업 목록에서 수업 참여 또는 수업 상세 진입
4. 모둠 상세 진입 시 AI 닉네임과 생성 이유 모달 확인
5. 채팅에서 일반 메시지를 전송하고 최신 메시지 자동 스크롤 확인
6. `ㅅㅂ`, `시발` 등 욕설성 표현 입력 후 전송 시도
7. AI 메시지 조언 모달에서 `warning`과 추천 문장 확인
8. 원문 전송이 막히고 수정안 적용 또는 다시 작성 흐름 확인
9. 대화가 쌓인 뒤 AI 개입 조언 모달에서 참여 유도 문장 확인

## 7. 기술 스택

| 영역 | 사용 기술 |
| --- | --- |
| Client | Flutter, Dart |
| Routing | Flutter Navigator, custom route generator |
| State | StatefulWidget, ChangeNotifier, ListenableBuilder |
| HTTP | http |
| Realtime Chat | socket_io_client |
| Local Session | shared_preferences |
| Environment | flutter_dotenv |
| File Upload | file_picker, presigned upload URL |
| Test | flutter_test, MockClient |

## 8. 아키텍처

프로젝트는 기능 단위 Clean Architecture를 따릅니다.

```text
lib/
  component/
    layout/
    theme/
  core/
    platform/
    session/
  features/
    auth/
      data/
      domain/
      presentation/
    student/
      data/
      domain/
      presentation/
    survey/
      data/
      domain/
      presentation/
  routes/
```

의존성 방향:

```text
presentation -> domain
data         -> domain
domain       -> external dependency 없음
```

이 구조를 통해 화면, 비즈니스 규칙, API 매핑을 분리했습니다. 예를 들어 채팅 AI 조언은 다음처럼 나뉩니다.

| 계층 | 역할 |
| --- | --- |
| Domain Entity | 위험도, 개입 타입, 기여도 분석 결과 모델링 |
| Repository Interface | 화면이 의존하는 추상 계약 |
| Remote Data Source | HTTP API 호출과 응답 파싱 |
| Repository Impl | 서버 응답을 앱 도메인 객체로 변환 |
| Presentation | 모달, 버튼, 전송 차단, 자동 스크롤 등 UX 처리 |

## 9. 주요 API 연동

| 기능 | Method | Endpoint | 클라이언트 처리 |
| --- | --- | --- | --- |
| 수업 목록 | GET | `/classes` | 학생 수업 목록 매핑 |
| 수업 참여 | POST | `/classes/join` | 수업 코드 기반 참여 |
| 모둠 상세 | GET | `/groups/{groupId}` | 모둠 정보 및 채팅 연결 준비 |
| 모둠 닉네임 | GET | `/groups/{groupId}/nickname` | 닉네임 모달 표시 |
| 메시지 조언 | POST | `/chat/message-advice` | 경고 및 수정안 모달 표시 |
| 대화 개입 조언 | POST | `/chat/intervention-advice` | 필요 시 참여 유도 모달 표시 |
| 기여도 분석 | POST | `/chat/contribution-analysis` | 역할 기반 분석 결과 매핑 |
| 과제 제출 | POST | `/assignments/submissions` | 파일 URL 또는 링크 제출 |
| 파일 업로드 URL | POST | `/storage/presigned-upload-url` | presigned URL 발급 |

서버가 AI 조언 API에서 `200` 또는 `201`을 반환해도 정상 응답으로 처리합니다.

## 10. 보안 및 개인정보 고려

- access token, refresh token, password 등 민감 값은 로그에 그대로 남기지 않도록 마스킹 처리
- 채팅 소켓 로그에서 메시지 본문과 토큰 값 노출 최소화
- AI 닉네임은 MBTI, 성별, 외모, 능력 낙인 표현을 직접 노출하지 않는 방향으로 설계
- 학생 화면에는 기여도 점수처럼 보이는 평가성 UI를 직접 노출하지 않음
- AI 판단은 최종 평가가 아닌 보조 지표로 다루는 구조

## 11. 실행 방법

### 11.1 요구 사항

- Flutter SDK
- Dart SDK 3.11 이상
- Android Studio 또는 Xcode
- API 서버 주소

### 11.2 환경 변수

프로젝트 루트에 `.env` 파일을 준비합니다.

```env
BASE_URL=http://localhost:8080
CHAT_SOCKET_URL=http://localhost:8080
```

`CHAT_SOCKET_URL`이 없으면 `BASE_URL` 또는 `API_BASE_URL`을 사용합니다.

### 11.3 의존성 설치

```bash
flutter pub get
```

### 11.4 실행

```bash
flutter run
```

웹으로 실행하려면 다음 명령을 사용할 수 있습니다.

```bash
flutter run -d chrome
```

## 12. 검증 방법

정적 분석:

```bash
flutter analyze
```

테스트:

```bash
flutter test
```

최근 확인한 주요 테스트:

```bash
flutter test test/features/student/data/repositories/student_repository_impl_test.dart test/features/student/presentation/widgets/group_chat_panel_test.dart
```

## 13. 현재 구현 상태

| 구분 | 상태 |
| --- | --- |
| 인증 UI | 구현 |
| 학생 수업 목록 | 구현 |
| 수업 참여 | 구현 |
| 설문 입력 | 구현 |
| 모둠 상세 조회 | 구현 |
| 모둠 닉네임 조회 | 구현 |
| 실시간 모둠 채팅 | 구현 |
| 메시지 전송 전 AI 조언 | 구현 |
| 그룹 대화 AI 개입 조언 | 구현 |
| 역할 기반 기여도 분석 API 매핑 | 구현 |
| 교사용 기여도 리포트 화면 | 확장 예정 |

## 14. 심사 포인트 요약

Modus의 차별점은 AI를 “평가자”가 아니라 “협업을 더 안전하게 만드는 보조자”로 설계했다는 점입니다.

- 표현 완화: 갈등이 생기기 전에 전송 직전 부드러운 문장 제안
- 참여 균형: 특정 학생을 공개 지목하지 않고 전체 대화 흐름을 자연스럽게 조정
- 익명성: 설문 기반 닉네임으로 부담은 낮추고 개성은 살림
- 공정성: 단순 발화량이 아니라 역할 기반 기여를 분석
- 안전성: 민감 정보 로그 노출 방지와 학생 점수화 UI 제한

## 15. 프로젝트 명령어 모음

```bash
flutter pub get
dart format .
flutter analyze
flutter test
flutter run
```
