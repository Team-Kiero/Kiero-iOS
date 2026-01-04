<p align="center">
  <img width="500" alt="image" src="https://github.com/user-attachments/assets/6a196306-e48d-403e-af1a-26ad4340b0c5" />
</p>
<br>

# Kiero-iOS
초등학생 자녀의 일정 관리와 자기주도적 습관 형성을 동시에 돕는
게이미피케이션 기반 성장 플랫폼입니다. 
<br>

## 🍎 iOS 파트
|    신혜연   |    안치욱   |   한현서   |    정윤아    |
| :-------------: | :----------: | :----------: |:----------: |
| <img src = "https://github.com/hyeyeonie.png" width ="200"> | <img src = "https://github.com/w0o0kgit.png" width ="200">  | <img src = "https://github.com/hyunseo-han.png" width ="200"> | <img src = "https://github.com/laura-jung.png" width ="200"> | 
|  `iOS Lead` |    `iOS Developer`   |  `iOS Developer`    |    `iOS Developer`   |
<br>

## 📁 프로젝트 구조
> Presentation 내에 뷰 기능 단위로 폴더링하여, 폴더 안에서 MVVM을 구현합니다.
```bash
Kiero
├── Kiero
│   ├── Application
│   │   └── AppDelegate
│   │   └── SceneDelegate
│   ├── Network
│   ├── Presentation
│   │   ├── Common
│   │   │   ├── Components
│   │   │   ├── Extensions
│   │   │   └── Resources
│   │   │       ├── Font
│   │   │       └── Assets
```
<br>

## ⚒️ 기술 스택
| 태그 | 기술 | 설명 |
|:---:|:---:|:---:|
| `UI 프레임워크` | UIKit | 안정적이고 풍부한 레퍼런스, 실무 적합성 |
|`아키텍처`| MVVM | 비즈니스 로직과 UI 로직 분리, 유지보수성 및 테스트 용이성 향상 |
|`네트워크`| Moya | Alamofire 기반의 네트워크 추상화, 열거형을 활용한 안전한 API 관리 |
| `애니메이션` | Lottie | JSON 기반의 가볍고 고품질인 벡터 애니메이션 렌더링 |
| `버전 관리`| Git, GitHub | 분산 버전 관리 시스템을 통한 형상 관리 및 협업 |
| `협업 도구`| Figma, Notion| UI/UX 디자인 리소스 공유 및 프로젝트 문서화, 태스크 관리 |
<br>

## 💬 Commit Message 규칙
### 태그 컨벤션

| 태그 | 설명 |
|:---:|:---:|
| `feat` | 새로운 기능 구현 |
| `style` | UI 및 스타일 관련 작업 |
| `fix` | 버그, 오류 해결 |
| `add` | feat 이외의 부수적인 코드 추가, 라이브러리 추가, 새로운 파일 생성 시 |
| `chore` | 사소한 수정 및 유지보수 작업 |
| `refactor` | 내부 로직은 변경 하지 않고 기존의 코드를 개선하는 리팩토링 시 |
| `docs` | README, 템플릿 등 프로젝트 내 문서 수정 |
| `setting` | 프로젝트 관련 설정 변경 |
| `merge` | 브랜치 머지 |
| `hotfix` | 긴급 수정 (배포 또는 개발 중 발생한 치명적 이슈 해결) |
<br>

### 커밋 컨벤션

1. 태그는 반드시 **소문자**로 작성합니다. 
2. 내용은 **한글**로 작성합니다.  
3. 제목은 **50자**를 넘지 않도록, 간단하게 **명령조**로 작성합니다.
4. 설명이 필요한 경우 **description**에 작성합니다.

* **커밋**: `[type] 작업내용`
  * ex) `[feat] 로그인 UI 구현`


* **이슈**: `[type] ~ 구현`
  * ex) `[feat] 로그인 UI 구현`


* **PR**: `[type] #이슈번호 작업내용`
  * ex) `[feat] #1 로그인 UI 구현`


* **머지**: `[merge] PR 제목`
<br>

### 브랜치 컨벤션

* `type/#이슈번호-작업할뷰` 세팅 관련 작업 등 특정 뷰가 없는 경우 뒤에는 생략 가능
  * ex) `feat/#1-DetailView`
<br>

## 🌊 Git Flow 전략

> **main 브랜치 보호 전략**: `main` 브랜치는 실제 배포 기준 브랜치로 사용하며, 직접적인 작업이나 커밋은 원칙적으로 금지합니다. 모든 변경 사항은 `develop` 브랜치를 거쳐 PR을 통해서만 `main`에 병합합니다.
<br>

### 작업 순서

1. **Issue 생성**: 작업할 내역에 대한 Issue를 생성합니다.
2. **Branch 생성**: 해당 이슈와 관련된 새 브랜치를 생성합니다.
3. **기능 구현**: 이슈 내용을 기반으로 기능을 구현하고 커밋합니다.
    * 커밋은 가능한 **기능 단위**로 쪼개서 진행합니다.
    * 작업이 끝나면 PR을 올리지 않더라도 항상 원격 저장소에 push 해둡니다.
4. **PR (Pull Request)**: `add` - `commit` - `push` 후 PR을 생성합니다.
5. **코드 리뷰**: PR 작성자 외의 팀원들이 코드를 리뷰합니다.
    * 필수 리뷰어: 2명 **(Lead 포함 필수)**
    * 리뷰 반영 사항이 있다면 수정 후 다시 Push 합니다. (자동으로 PR에 반영됨)
6. **Merge**: PR 작성자가 본인의 브랜치를 Merge 합니다.
    * merge 전후 상황을 팀원들에게 반드시 공유합니다.
7. **Pull**: Merge 후 로컬에서 `main`으로 이동하여 반드시 `git pull`을 받아 최신 상태를 유지합니다.
<br>

## 📏 코딩 컨벤션

### 네이밍

* **약어 사용 금지**, Full Name 지향
* **Class, Struct, Protocol**: `UpperCamelCase`
* **Variable, Constant**: `lowerCamelCase`
* **Function**: `lowerCamelCase` (동사로 시작)
* **Enum**: 각 Case에는 `lowerCamelCase`

### 코드 레이아웃 & 포맷

* **Colon(:)**: 콜론의 오른쪽에만 공백을 둡니다. (`let names: [String: String]?`)
* **줄바꿈 규칙**: 파라미터가 많을 경우 줄바꿈(Xcode `Ctrl+M` 스타일)을 지향합니다.
* **파라미터에 클로저가 2개 이상** 존재할 경우 **무조건 내려쓰기**를 적용합니다.
* **빈 줄**: 빈 줄에는 공백이 포함되지 않도록 합니다.
* **Import 순서**:
```swift
import UIKit

import SnapKit
import Then
```

### 코드 구조

* **메서드 순서**: `setStyle` → `setUI` → `setLayout` → `setAddTarget` → `setDelegate`
  * `setStyle()`: backgroundColor 등 속성 지정
  * `setUI()`: addSubview (계층 설정)
  * `setLayout()`: SnapKit 제약조건 설정
* **MARK 주석**: MARK 구문 위와 아래에는 공백을 둡니다.
```swift
// MARK: - Properties

// MARK: - UI Components

// MARK: - Life Cycle

// MARK: - Setup Methods

// MARK: - Bind

// MARK: - Action

```

### 프로그래밍 가이드라인

* **Type Annotation 필수 사용**:
```swift
// Good
let name: String = "철수"
let height: Float = 10.0

// Bad
let name = "철수"
```
* **Delegate Pattern**: `UICollectionViewDelegate` 등 시스템 프로토콜은 **Extension**으로 분리하여 관리합니다.
* **기타 규칙**: `self` 키워드 사용 지향 (필요한 경우 제외)
* **Force Unwrapping (`!`) 절대 금지**
* `viewDidLoad()`, `init()` 내부에서는 구체적인 로직 대신 **함수 호출**만 작성
* 불필요한 주석 및 공백 제거
