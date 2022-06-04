# CH1. Hello, RxSwift!

## 1.0. RxSwift

정확히 RxSwift는 무엇인가? 다음으로 정의 내릴 수 있다.

> ***RxSwift** is a library for composing asynchronous and event-based code by using observable sequences and functional style operators, allowing for parameterized execution via schedulers*.
>
> RxSwift는 관찰 가능한 시퀀스와 기능적인 operator를 사용하여 비동기 및 이벤트 기반 코드를 구성하기 위한 라이브러리로, scheduler를 통해 매개변수화된 실행을 가능하도록 한다.

<img src="https://assets.alexandria.raywenderlich.com/books/rxs/images/ab467194f1beba81837c3295692b7df1f364e51219988ab8c73eb8381fa18c4f/original.png" width="30%" />

조금 더 이해할 수 있도록 표현하자면,

> ***RxSwift**, in its essence, simplifies developing asynchronous programs by allowing your code to react to new data and process it in a sequential, isolated manner*.
>
> 본질적으로 RxSwift는 코드가 새로운 데이터에 반응하고 순차적이고 격리된 방식으로 처리할 수 있도록 하여 비동기 프로그램 개발을 단순화한다.



## 1.1. Introduction to asynchronous programming

비동기 프로그래밍을 간단하고 실용적인 언어로 설명하려고 하면 다음과 같은 내용이 연상될 수 있다.

iOS 앱은 어느 순간이든, 다음과 같은 작업을 수행할 수 있다.

```
- 버튼 탭에 반응하기
- 텍스트 필드 포커스 잃음에 따라 키보드 애니메이션하기
- 인터넷으로부터 대용량 사진 다운로드하기
- 데이터 비트(bits)를 디스크에 저장하기
- 오디오 재생하기
```

이 모든 일들이 동시에 일어나는 것처럼 보이지만, 키보드 애니메이션이 사라진다해도 앱의 오디오는 멈추지 않는다.

<img src="https://assets.alexandria.raywenderlich.com/books/rxs/images/af574cae053cb119e63a24c7f3c7ec7f67e31025d845696a29d2e25cb1df198b/original.png" width="50%" />

모든 다른 bits의 프로그램들이 서로의 실행을 차단하지 않는다. iOS는 다양한 실행 컨텍스트에서 서로 다른 스레드에서 서로 다른 작업을 수행하고 장치 CPU의 서로 다른 코어에서 수행할 수 있는 다양한 종류의 API를 제공한다.

그러나 실제로 병렬적으로 실행되는 코드를 작성하는 것은 특히 다른 코드 비트가 동일한 데이터 조각으로 작업해야 하는 경우 다소 복잡해진다. 어떤 코드가 데이터를 먼저 업뎃하는지 또는 어떤 코드가 최신 값을 읽는지 확실히 알기 어렵다.



### 1.1.1. Cocoa and UIKit asynchronous APIs

Apple은 iOS SDK 내에서 비동기 코드를 작성하는 데 도움이 되는 수많은 API를 제공해오고 있다. 

주로 이런 것들이 있는데

```
- NotificationCenter: 사용자가 디바이스 방향 변경 또는 키보드 show/hide 이벤트에 따른 코드 실행
- The delegate pattern: 다른 오브젝트를 대신 또는 함께 작동하는 오브젝트 정의 가능
- Grand Central Dispatch: 작업 실행을 추상화하는 데 도움, 코드 블록을 순차적으로나 동시에 아니면 지연 후에 실행하도록 스케줄 가능
- Closures: 코드 실행 후 코드에 전달할 수 있는 분리된 코드 조각을 만들 수 있음
- Combine: iOS 13에 도입되는 Swift 반응형 비동기 코드를 작성하는 Apple 프레임워크
```

어떤 API를 사용하냐에 따라 앱을 일관된 상태로 유지하기 어려워지는데,

예를 들어 delegate pattern이나 NotificationCenter와 같은 오래된 API를 사용하는 경우 앱의 상태를 항상 일관되게 유지하기 위해 더 많은 노력이 필요하다.

비동기식 코드 작성의 핵심 문제는

- 작업이 수행되는 순서
- 작업 중 변경 가능한 공유 데이터

일반적으로 대부분의 UI 작업이나 클래스 코드 구문들은 비동기적이다. 따라서 어떤 앱 코드를 작성하였을 때 매번 어떤 순서로 작동하는지 가정하는 것은 불가능하고, 앱의 코드는 사용자 입력, 네트워크 활동 또는 기타 OS 이벤트와 같은 다양한 외부 요인에 따라 완전히 다른 순서로 실행될 수 있다!

### 1.1.2 Asynchronous programming glossary

**비동기 프로그래밍 용어**

RxSwift는 비동기, 반응형, 함수형 프로그래밍에 매우 밀접하게 관련되어 있어 다음 용어들을 먼저 이해하면 좋다.

#### 1) State, and specifically, shared mutable state

**state**는 하드웨어와 소프트웨어는 그대로 정상 작동하지만, 시간이 지나고 사용할수록 데이터의 교환 등으로 인해 상태가 변한다. 즉, state가 바뀐다는 것

> 특히 여러 비동기 구성 요소 간에 공유될 때 앱의 state(상태)를 관리하는 것은 RxSwift에서 다루게 될 포인트 중 하나

#### 2) Imperative programming | 명령형 프로그래밍

명령형 프로그래밍은 명령문을 사용하여 프로그램의 상태를 변경하는 프로그래밍으로, 앱에 작업을 수행하는 시기와 방법을 앱에 정확히 알려준다. 문제는 인간이 복잡하고 비동기적인 앱을 만들기 위해 명령형 코드를 사용하는 것이 너무나 어렵다는 점!

다음 예제 코드를 보자면,

``` swift
override func viewDidAppear(_ animated: Bool) {
  super.viewDidAppear(animated)

  setupUI()
  connectUIControls()
  createDataSource()
  listenForChanges()
}
```

	- 각 메서드들이 어떤 동작을 하는지 알 수 없다.
	- VeiwController 자체의 프로퍼티를 업데이트 하는지도 알 수 없고,
	- 의도한 순서대로 메서드가 실행될지도 보증할 수 없다.
	- 또한, 누군가의 실수로 메서드 호출 순서가 바뀌었다면, 앱이 다르게 동작할 수 있다.

#### 3) Side effects

위에서 언급한 두 가지에 대한 부작용, 즉 현재 범위를 벗어난 상태에서 일어나는 모든 변화를 의미한다.

위 코드로 예를 들자면 아래와 같은 부작용이 발생한다.

```
1. connectUIControls()는 아마도 일부 UI 구성요소에 일종의 이벤트 핸들러를 첨부할 것
2. 이로 인해 뷰의 상태가 변경되므로 부작용이 발생
```

이처럼 언제든 디스크에 저장된 데이터 또는 스크린 상에서 label의 text를 업뎃한다면 부작용이 발생한다.

> 부작용 자체가 나쁘다는 것이 아니라, 문제는 컨트롤이 가능하냐는 것

<img src="https://assets.alexandria.raywenderlich.com/books/rxs/images/a807e16ddce3a43a26ac84b39a505926a0926e7cbcb5090298d3b080d3d8ae3d/original.png" width ="50%" />

- 어떤 코드가 부작용을 일으키는지, 어떤 코드가 단순히 데이터를 처리하고 출력하는지 결정할 수 있어야 한다.

**:arrow_right: RxSwift는 이러한 이슈들을 해결 가능하게 해준다.**

#### 4) Declarative code | 선언형 코드

- 명령형 프로그래밍에서는 마음대로 상태를 변경한다.

- 합수형 프로그래밍에서는 부작용을 최소화하는 코드를 지향한다.

RxSwift는 이 두가지의 장점만 결합하여 동작하게 한다.

- **자유로운 상태 변화 + 추적/예측 가능한 결과값**

선언형 코드를 통해 동작을 정의할 수 있으며, RxSwift는 관련 이벤트가 있을 때마다 이러한 동작을 실행하고 함께 작업할 변경 불가능한 데이터를 제공한다. 즉, 변경 불가능한 데이터로 작업하고 순차적이고 결과론적인 방식으로 코드를 실행할 수 있다.

#### 5) Reactive systems

반응형 시스템은 다소 추상적인 용어이며 다음 특성의 대부분 또는 모두를 나타내는 웹 또는 iOS 앱을 다루게 된다.

- 반응형(Responsive): 항상 최신 앱 상태를 나타내는 최신 UI를 유지하고자 함
- 복원력(Resilient): 각 동작들은 독립적으로 정의되며 유연한 에러 복구를 위해 제공됨
- 탄력성(Elastic): 코드는 다양한 작업부하를 처리하며, 종종 lazy pull 기반 컬렉션 수집, 이벤트 제한 및 자원 공유와 같은 기능을 구현함
- 메시지 전달(Message-driven): 구성요소들은 향상된 재사용성과 고유의 응집도를 위해 메시지 기반 통신을 사용하여 라이프 사이클과 클래스 구현을 분리함



## 1.2. Foundation of RxSwift

RxSwift는 변경 가능한 상태를 처리하고 이벤트 시퀀스를 구성하고 재사용 가능성 및 코드 모듈화와 같은 아키텍처 개념을 개선할 수 있다.

Rx code의 세 가지 building block(구성요소); **observables**(생산자), **operators**(연산자), **schedulers**(스케줄러)에 대해 알아보자

### 1.2.1. Observables

- `Observable<Element>`는 Rx 코드의 기반
- element 형태의 일반 데이터의 변경 불가능한 스냅샷을 "전달"할 수 있는 이벤트 시퀀스를 비동기식으로 생성하는 기능
- 즉, 시간이 지남에 따라 다른 객체에서 내보내는 이벤트 또는 값을 구독할 수 있다.
- Observable 클래스를 사용하면 한 명 이상의 관찰자가 실시간으로 모든 이벤트에 반응하고 앱의 UI를 업데이트하거나 새로운 수신 데이터를 처리하고 활용할 수 있다.

Observable이 준수하는 ObservableType 프로토콜은 매우 간단하다. Observable은 세 가지 유형의 이벤트만 방출할 수 있다.

- **A `next` event**: 최신 데이터 값을 전달하는 이벤트로, 이틀 통해 observer가 값을 받을 수 있다. 종료 이벤트가 발생할 때 까지 무한정으로 해당 이벤트를 방출할 수 있다.
- **A `completed` event**: 성공적으로 이벤트 시퀀스를 종료하는 이벤트이다. Observable이 라이프 사이클을 성공적으로 완료하고 더 이상 이벤트를 방출하지 않는다는 것을 의미한다.
- **An `error` event**: Observable이 에러와 함께 종료되고 추가 이벤트를 내보내지 않는다.

아래와 같이 시간이 지남에 따라 발생하는 비동기 이벤트를 생각해보면, 

<img src="https://assets.alexandria.raywenderlich.com/books/rxs/images/f8d3cff7dafeb96562b1d9031cf41b30959aea0c036be76b0bb03070e392fed9/original.png" width="50%" />

<img src="https://assets.alexandria.raywenderlich.com/books/rxs/images/5e255ce9e0cb680c862ff81cddb3f721957ced5c1fa019660974b265367f0fd2/original.png" width="50%" />

- 세 가지 유형의 Observable 이벤트는, `Observable` 또는 `Observer`의 본질에 대한 어떤 가정도 하지 않는다.
- 따라서 델리게이트 프로토콜을 사용하거나, 클래스 통신을 위해 클로저를 삽입할 필요가 없다.

#### Finite observable sequences

끝이 있는 한정적인 Observable이 있다. 에러로 끝이 나던, 성공으로 끝이 나던 끝이 있는 observable를 말한다. 다운로드 코드로 예를 들어보자면,

```
- 먼저, 다운로드를 시작하고 들어오는 데이터를 관찰하기 시작함
- 파일의 일부가 도착할 때 데이터 청크를 반복적으로 수신함
- 네트워크 연결이 끊어지면 다운로드가 중지되고 연결시간이 초과되어 오류 발생
- 또는, 코드가 파일의 모든 데이터를 다운로드하면 성공적으로 완료
```

위 워크플로우는 전형적인 observable의 생명주기를 정확하게 설명해준다.

``` swift
API.download(file: "http://www...")
   .subscribe(
     onNext: { data in
      // Append data to temporary file
     },
     onError: { error in
       // Display error to user
     },
     onCompleted: {
       // Use downloaded file
     }
   )
```

- `API.download(file:)`은 네트워크를 통해 들어오는 `Data`값을 방출하는 `Observable<Data>` 인스턴스를 리턴할 것이다.
- `onNext` 클로저를 통해 `next` 이벤트를 받을 수 있다. 예제에서는 받은 데이터를 디스크의 `temporary file`에 저장하게 될 것이다.
- `onError` 클로저를 통해 `error` 이벤트를 받을 수 있다. alert 메시지 같은 action을 취할 수 있을 것이다.
- 최종적으로 `onCompleted` 클로저를 통해 `completed` 이벤트를 받을 수 있으며, 이를 통해 새로운 viewController를 push하여 다운로드 받은 파일을 표시하는 등의 엑션을 취할 수 있을 것이다.

#### Infinite observable sequences

자연적으로 또는 강제적으로 종료되어야 하는 파일 다운로드 같은 활동과 달리, 단순히 무한한 sequence가 있다. 보통 UI 이벤트는 무한하게 관찰가능한 sequence이다.

예를 들어, 기기의 가로/세로 모드에 따라 반응해야 하는 경우를 생각해 보자면,

```
- NotificationCenter에서 UIDeviceOrientationDidChange 알림에 대한 관찰자로 클래스를 추가함
- 방향 변경을 처리하기 위해 메서드 콜백을 제공
- UIDevice에서 현재 방향을 가져와 최신 값에 따라 반응
```

- 방향전환이 가능한 디바이스가 존재하는 한, 이러한 연속적인 방향 전환은 자연스럽게 끝날 수 없다.
- 결국 이러한 시퀀스는 사실상 무한하기 때문에, 항상 최초값을 가지고 있어야 한다.
- 사용자가 디바이스를 절대 회전하지 않는다고 해서 이벤트가 종료된 것도 아니다. 단지 이벤트가 발생한 적이 없을 뿐.

이 점을 RxSwift로 대응한다면,

``` swift
UIDevice.rx.orientation
  .subscribe(onNext: { current in
    switch current {
    case .landscape:
      // Re-arrange UI for landscape
    case .portrait:
      // Re-arrange UI for portrait
    }
  })
```

- `UIDevice.rx.orientation`은 `Observable<Orientation>`을 통해 만든 가상의 코드

- 이를 통해 현재 방향을 받을 수 있고, 받은 값을 앱의 UI에 업데이트 할 수 있다.
- 해당 Observable에서는 절대 발생하지 않을 이벤트이기 때문에 `onError`나 `onCompleted` parameter는 생략 가능하다.

### 1.2.2. Operators

- `observableType`과 `Observable` 클래스의 구현은 보다 복잡한 논리를 구현하기 위해 함께 구성되는 비동기 작업을 추상화하는 많은 메소드가 포함되어 있음. 
- 이러한 메소드는 매우 독립적이고 구성가능하므로 보편적으로 Operators(연산자) 라고 불림.
- 이러한 Operator(연산자) 들은 주로 비동기 입력을 받아 부수작용 없이 출력만 생성하므로 퍼즐 조각과 같이 쉽게 결합할 수 있다.
- 예를 들어 `(5 + 6) * 10 - 2` 라는 수식을 생각해보자

- `*`, `()`, `+`, `-` 같은 연산자를 통해 데이터에 적용하고 결과를 가져와서 해결될 때까지 표현식을 계속 처리하게 된다.
- 비슷한 방식으로 표현식이 최종값으로 도출 될 때까지, `Observable`이 방출한 값에 Rx 연산자를 적용하여 부수작용을 만들 수 있다.

- 다음은 앞서 방향전환에 대한 예제에 Rx 연산자를 적용시킨 코드이다.

``` swift
 UIDevice.rx.orientation
 	.filter { value in
 		return value != .landscape
 	}
 	.map { _ in
 		return "Portrait is the best!"
 	}
 	.subscribe(onNext: { string in
 		showAlert(text: string)
 	})
```

- `UIDevice.rx.orientation`이 `.landscape` 또는 `.portrait` 값을 생성할 때 마다, Rx는 각각의 연산자를 데이터의 형태로 방출함.

  <img src="https://assets.alexandria.raywenderlich.com/books/rxs/images/4733ac0cfa80353413c2f1e0a5058322dfc7daca1d6cd13323b5b3fe85378083/original.png" width="30%" />

  - 먼저 `filter` 는 `.landscape` 가 아닌 값만을 내놓는다. 만약 디바이스가 landscape 모드라면 나머지 코드는 진행되지 않을 것이다. 왜냐하면 `filter`가 해당 이벤트의 실행을 막을 것이기 때문에.
  - 만약 `.portrait` 값이 들어온다면, `map` 연산자는 해당 방향값을 택할 것이며 이것을 `String` 출력으로 변환할 것이다. ("`Portrait is the best!`")
  - 마지막으로, `subscribe`를 통해 결과로 `next` 이벤트를 구현하게 된다. 이번에는 `String` 값을 전달하고, 해당 텍스트로 alert을 화면에 표시하는 method를 호출한다.

- 연산자들은 언제나 입력된 데이터를 통해 결과값을 출력하므로, 단일 연산자가 독자적으로 할 수 있는 것보다 쉽게 연결 가능하며 훨씬 많은 것을 달성할 수 있다.

### 1.2.3. Schedulers

- 스케줄러는 Rx에서 dispatch queue와 동일한 것. 다만 훨씬 강력하고 쓰기 쉽다.
- RxSwift에는 여러가지의 스케줄러가 이미 정의되어 있으며, 99%의 상황에서 사용가능하므로 아마 개발자가 자신만의 스케줄러를 생성할 일은 없을 것이다.
- 이 책의 초기 반 정도에서 다룰 대부분의 예제는 아주 간단하고 일반적인 상황으로, 보통 데이터를 관찰하고 UI를 업데이트 하는 것이 대부분이다. 따라서 기초를 완전히 닦기 전까지 스케줄러를 공부할 필요는 없다.
- 기존까지 GCD를 통해서 일련의 코드를 작성했다면 스케줄러를 통한 RxSwift는 다음과 같이 돌아간다.

<img src="https://assets.alexandria.raywenderlich.com/books/rxs/images/28bdd14bbb8cebcb00fcdc724a10d4f34c19a2b14bcdda5c7ed1f59af513b6f4/original.png" width="50%" />

- 각 색깔로 표시된 일들은 다음과 같이 각각 스케줄(1, 2, 3...)된다.
  - `network subscription`(파랑)은 (1)로 표시된 `Custom NSOperation Scheduler`에서 구동된다.
  - 여기서 출력된 데이터는 다음 블록인 `Background Concurrent Scheduler`의 (2)로 가게 된다.
  - 최종적으로, 네트워크 코드의 마지막 (3)은 `Main Thread Serial Scheduler`로 가서 UI를 새로운 데이터로 업데이트 하게 된다.
- 지금 스케줄러가 편리하고 흥미로워 보이더라도 너무 많은 스케줄러를 사용할 필요는 없다. 일단 기초부터 닦고 후반부에 깊이 들어가보자.

## 1.3. App Architecture

- RxSwift는 기존의 앱 아키텍처에 영향을 주지 않는다. 주로 이벤트나 비동기 데이터 시퀀스 등을 주로 처리하기 때문이다.
- 따라서 Apple 문서에서 언급된 MVC 아키텍처에 Rx를 도입할 수 있다. 물론 MVP, MVVM 같은 아키텍처를 선호한다면 역시 가능하다.
- Reactive 앱을 만들기 위해 처음부터 프로젝트를 시작할 필요도 없다. 기존 프로젝트를 부분적으로 리팩토링하거나 단순히 앱에 새로운 기능을 추가할 때도 사용가능하다.
- Microsoft의 MVVM 아키텍쳐는 데이터 바인딩을 제공하는 플랫폼에서 이벤트 기반 소프트웨어용으로 개발되었기 때문에, 당연히 RxSwift와 MVVM는 같이 쓸 때 아주 멋지게 작동한다.
  - ViewModel을 사용하면 `Observable<T>` 속성을 노출할 수 있으며 ViewController의 UIKit에 직접 바인딩이 가능하다.
  - 이렇게 하면 모델 데이터를 UI에 바인딩하고 표현하고 코드를 작성하는 것이 매우 간단해진다.
- 이 책에서는 MVC 패턴을 다룬다고 한다.
- 다음은 MVVM 아키텍처

<img src="https://assets.alexandria.raywenderlich.com/books/rxs/images/0625dc8cc2e93bdc9324fafea84fadaaf4729dfd39d114996486bb185bdb53e0/original.png" width="50%" />



## 1.4. RxCocoa

- RxCocoa는 RxSwift의 동반 라이브러리로, UIKit과 Cocoa 프레임워크 기반 개발을 지원하는 모든 클래스를 보유하고 있다.

  - RxSwift는 일반적인 Rx API라서, Cocoa나 특정 UIKit 클래스에 대한 아무런 정보가 없다.

- 예를들어, RxCocoa를 이용하여 `UISwitch`의 상태를 확인하는 것은 다음과 같이 매우 쉽다.

  ```swift
   toggleSwitch.rx.isOn
   	.subscribe(onNext: { enabled in
   		print( enabled ? "It's ON" : "it's OFF")
   	})
  ```

  - RxCocoa는 `rx.isOn`과 같은 프로퍼티를 `UISwitch` 클래스에 추가해주며, 이를 통해 이벤트 시퀀스를 확인할 수 있다.

- RxCocoa는 `UITextField`, `URLSession`, `UIViewController` 등에 `rx`를 추가하여 사용한다.

## 1.5. Installing RxSwift

### via CocoaPods

``` swift
use_frameworks!

target 'MyTargetName' do
  pod 'RxSwift', '~> 5.1'
  pod 'RxCocoa', '~> 5.1'
end

```