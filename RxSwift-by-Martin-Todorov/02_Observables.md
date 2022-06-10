## 0️⃣ Observable 이 등장하게 된 배경

ReactiveX 문서에서는

"우리는 보통 프로그래밍을 할 때, 작성한 명령어들이 우리가 작성한 순서대로 차례대로 실행되어 점진적으로 완성되는 방식에 익숙할 것이다."

즉, 절차식 프로그래밍에 익숙하다고 언급하고 있다.

하지만 이와 다르게 ReactiveX에서는

**"여러 명령어들은 병렬적으로 실행된다. 즉, 어떠한 순서에 따라 실행되는 것이 아니다. 그리고 병렬적으로 실행된 명령어들의 결과는 observer에 의해 임의적으로 나중에 수집된다!"**

라고 설명 되어있었다.

observer에 의해 임의적으로 나중에 수집된다는 말은 다음의 설명을 통해 이해할 수 있다.

"ReactiveX 방식으로 프로그래밍을 하려면 먼저 데이터를 수집하고 조작하는 어떠한 **체계(=mechanism)**를 정의해야 한다. 이 체계를 **Observable**이라고 하고 observer가 이 Observable이라는 데이터 수집 및 조작 체계를 구독하는 것이다."

"observer가 Observable을 구독하는 시점에 Observable은 observer와 함께 작동한다. 이 observer는 Observable이 방출하는 것에 반응하고, Observable이 방출하는 것을 잡기 위해 Observable을 감시하고 있는 것이다."

설명을 덧붙이자면,

ReactiveX 프로그래밍의 특징인 명령어를 병렬적으로 동시에 실행시키는 작업을 하기 위해서는 Observable과 observer이라는 것이 필요하다는 것이고,

이 때, observer는 Observable을 구독함으로써 감시하고 있다는 것이다.

이렇게 observer가 Observable을 구독하는 순간부터 Observable은 observer와 함께 작동되고, observer는 Observable이 방출하는 어떤 것에 반응하거나 그것을 잡는 역할을 한다.

여기서 Observable은 자신을 구독하고 있는 observer에게 "observer’s method"들을 호출함으로써 item을 방출하거나 notification을 보낸다.

이렇게 Observable과 observer가 존재하는 model을 **Reactor Pattern(반응자 패턴)**이라고 부르기도 한다.



## 1️⃣ Observable은 무엇일까?

Observable은 Rx의 중심이다. Observable sequence, Observable, sequence 등의 말들이 많이 쓰이는데 이는 모두 동일한 말이다. 혹은 stream이라는 말을 들을 수 있지만 모두 sequence라는 것을 기억할 것!

Observable은 단지 sequence이며 특별한 힘을 가졌다. 가장 강력한 힘 중 하나는 **비동기적**이라는 것

Observable은 이벤트들을 생산하고, 이 과정을 **emitting**이라고 한다. 이벤트는 값을 가질 수도 있고 탭과 같은 제스쳐를 가질 수도 있다.

이를 개념화하는 가장 좋은 방법 중 하나는 타임라인에 표시된 값인 **마블 다이어그램**을 이용하는 것!

<img src="https://assets.alexandria.raywenderlich.com/books/rxs/images/c1161239a67d91b694c2ef4cf9f746b75a8ac5f29e8c540207b89f5792944988/original.png" width="50%" />

- 타임라인 위에 시퀀스의 값들이 표현되어 있으며 왼쪽에서 오른쪽으로 가는 것은 시간을 의미한다. 

- 원 안에 값이 있는 것이 표현된 것은 방출 (emitted)되었다는 것을 의미한다.
- 시간은 얼마나 걸리냐고? - Observable의 수명 내내 어느 시점에 있을 수 있다.
  - 이에 대한 자세한 내용은 Observable의 수명주기에 대해 얘기해보자.

<img src="https://assets.alexandria.raywenderlich.com/books/rxs/images/3d4b3fffebf390da9c130b6762c2936d29a811b69c8d4844acc78ad7644e1ac3/original.png" width="30%" />

(뜬금없는데 이 그림 너무 귀욥다 ㅋㅋㅎ)



## 2️⃣ Lifecycle of an observable

Observable이 요소를 방출하면, **Next** 이벤트라고 알려진 이벤트에서 발생한다.

마블 다이어그램에 vertical bar가 있다면 이는 Observable이 더 이상 쓰이지 않는다는 것을 의미하며 **completed event**이다. 혹은 terminated라고 표현한다.

- 예를 들어 dismissed된 뷰의 탭들이 있다.

<img src="https://assets.alexandria.raywenderlich.com/books/rxs/images/110965d6b04dbdaf604408dba4f164f3b0b3e6341a469a8bdb88bcd45159b553/original.png" width="50%" />

만약 에러가 발생한 경우에는 빨간색으로 X가 표시되며 error event라고 한다. 에러가 발생하면 더 이상 이벤트를 발생시키지 않고 종료한다.

<img src="https://assets.alexandria.raywenderlich.com/books/rxs/images/13887a1c8922fcc3bb2914d01aa5ed5ff38157ee44aed97ea89fd15389a648fd/original.png" width="50%" />

Event는 열거형으로 표현되며, Element를 담고 있는 `.next`, Error를 담고 있는 `.error`, 그리고 종료를 나타내는 `.completed`로 표현된다.

``` swift
/// Represents a sequence event.
///
/// Sequence grammar:
/// **next\* (error | completed)**
public enum Event<Element> {
    /// Next element is produced.
    case next(Element)

    /// Sequence terminated with an error.
    case error(Swift.Error)

    /// Sequence completed successfully.
    case completed
}
```

### 요약하자면

- Observable은 element를 포함하는 next event를 방출한다.
- 종료 이벤트(error or completed)가 발생할 때까지 작업을 계속 유지할 수 있다.
- Observable이 종료되면 더 이상 아무 것도 방출할 수 없다.(= 이벤트 생성도 X)

ReactiveX에서는 관습적으로 **Observable이 onNext 함수를 호출하는 것 자체를 item의 방출이라고 부르고,**

onNext를 제외한 **onCompleted 함수와 onError 함수를 호출하는 것을 notification을 호출한다고 부른다.**

## 3️⃣ Observables 만들기

### Observable.just

- Observable의 타입 메서드
  (Rx에서는 메서드를 operator라고 한다.)
- 하나의 요소만 가지고 있는 Observable sequence를 만든다.

### Observable.of

- 타입을 명시하지 않아도 되며 여러개의 요소들을 반환할 수 있다.
- of는 variadic(임의 개수의 인자를 지원하는) parameter를 취한다.
  - 따라서 Observable array를 만들고 싶다면 Observable.of([one,two]) 를 사용하면 된다.
    (Observable.of( one, two)은 다른거임!)
  - 이때 Observable array는 하나의 element를 가지고 있다.
    <img src="https://assets.alexandria.raywenderlich.com/books/rxs/images/908404dc49b99f3f54c412d4c7a047856f51c5f69f12979ca3c720748ce60d6d/original.png" width="30%" />

### Observable.from

- array를 individual element로 풀어서 Observable을 만든다.
  ➡️ from element는 array만 가능!

``` swift
example(of: "just, of, from") {
  // 1
  let one = 1
  let two = 2
  let three = 3

  // 2
  let observable = Observable<Int>.just(one)
  let observable2 = Observable.of(one, two, three)
  let observable3 = Observable.of([one, two, three])
	let observable4 = Observable.from([one, two, three])
}
```



## 4️⃣ Observables에 구독하기

RxSwift의 Observers는 우리에게 익숙한 observer에게 broadcast 형식으로 알려주는 `NotificationCenter`와 다르다.

사실 동작 자체는 비슷하지만, 보통 `.default` instance만 쓰는 `NotificationCenter`와 다르게 Observable 각각이 다른 인스턴스이다.

또한 중요한 점은 Observable은 subscriber가 없다면 메시지를 보내거나 어떤 액션도 취하지 않는다는 점이다.

subscribe operator를 확인해보면 escaping closure가 Element 타입의 Event를 인자로 취하는 것을 볼 수 있고, 아무것도 리턴하지 않는다는 것을 알 수 있다. 그리고 subscribe는 Disposable을 리턴한다.

이때 단순히 subscribe를 한다면 모든 이벤트를 받을 가능성이 있다. 이때 next event만 element를 가지고 있기 때문에 event.element에 접근하려 했을 때 element는 optional이다.

- 이러한 불편함 때문에 subscribe에서는 각 이벤트에 대한 단축어가 있다.

``` swift
observable.subscribe { event in
                      // unwrapping is required because only next event has a element
                      if let element = event.element {
                        print(element)
                      }
}
// short cut of next event
observable.subscribe(onNext: { element in
                             print(element)	// not optional
                             })
```

만약 어떠한 원소도 없는 Observable을 만들고 싶다면 Observable.empty()를 사용하자! .completed event만 방출할 것이다.

- 추론이 불가능하다면 Observable은 특정한 인자로 정의가 되어야 한다.
- 즉시 종료되는 Observable이 리턴되어야 하거나 의도적으로 아무런 값이 없는 Observable이 필요할 때 유용하게 쓰일 것.

empty와 반대로 never라는 operator가 있다. Observable.never()로 사용되며, 이는 어떠한 것도 방출하지 않으며, 종료되지도 않는 observable이다.

- 이는 무한기간을 나타내는데 사용할 수 있다.

Observable.range()로 특정 범위만큼 element를 가진 Observable도 만들 수 있다.

- 예제

  ``` swift
  example(of: "range") {
    // 1
    let observable = Observable<Int>.range(start: 1, count: 10)
  
    observable
      .subscribe(onNext: { i in  
        // 2
        let n = Double(i)
  
        let fibonacci = Int(
          ((pow(1.61803, n) - pow(0.61803, n)) /
            2.23606).rounded()
        )
  
        print(fibonacci)
    })
  }
  ```



## 5️⃣ Disposing and terminating

Observable은 구독(subcription)을 받기 전 까지는 아무것도 하지 않는다. 구독은 Observable이 끝날 때까지 일하게 한다. 또한 직접 구독을 취소하여 Observable을 종료시킬 수 있다.

직접적으로 구독을 취소시키기 위해서 `dispose()`를 호출하자. 이때 observable은 이벤트를 더 이상 발생시키지 않을 것이다.

- 일일이 구독을 관리하는 것이 귀찮을 수 있는데, RxSwift에서는 DisposeBag이라는 타입을 포함한다.
- disposebag은 disposable을 들고 있다가 disposebag이 deallocated(=할당 해제) 될 때 dispose()를 각각 호출한다.
- subscribe를 통해서 disposable이 리턴되면 이를 disposebag에 구독시키는 것이 자주 활용되는 패턴일 것이다.

``` swift
example(of: "dispose") {
  // 1
  let observable = Observable.of("A", "B", "C")

  // 2
  let subscription = observable.subscribe { event in
    // 3
    print(event)
  }
  
  // 4
  subscription.dispose()
}
```

``` swift
example(of: "DisposeBag") {
  // 1
  let disposeBag = DisposeBag()

  // 2
  Observable.of("A", "B", "C")
    .subscribe { // 3
      print($0)
    }
    .disposed(by: disposeBag) // 4
}
```

create operator를 이용하면 Observable이 subscriber에게 방출한 모든 이벤트를 설정할 수 있다.

아래 그림을 보다시피, subscribe 매개변수는 AnyObserver를 사용하고 Disposable을 반환하는 escaping closure이다.

AnyObserver는 관찰 가능한 시퀀스에 값을 추가하는 것을 용이하게 하는 제네릭 유형이며, 이는 subscriber에게 전달된다.

<img src="https://assets.alexandria.raywenderlich.com/books/rxs/images/fc9b2037734c93600f64c42c2c55dc6cb3cc808fbb22345959fae13a06935ad1/original.png" width="50%" />

``` swift
example(of: "create") {
  Observable<String>.create { observer in
  // 1
  observer.onNext("1")

  // 2
  observer.onCompleted()

  // 3
  observer.onNext("?")

  // 4
  return Disposables.create()
	}
}
```

- 이때 마지막 "?"는 호출이 되지 않는다.

  - completed가 있기 때문!
  - 또한 .next와 .onCompleted 사이에 onError가 있는 경우에는 completed는 호출 되지 않는다.(종료되었으므로)

- 만약 dispose도 없고, 끝나지 않는다면 memory leak을 만드는 것이다. Observable은 영원히 끝나지 않을 것이며 폐기되지도 않을 것이다.

  > disposeBag을 통해서 어차피 dispose 가 호출되기 때문에 complete 혹은 error 이벤트는 신경 안써도 되지 않을까?
  >
  > - 맞다. 어차피 disposebag이 dispose 시켜준다.
  >
  > dispose 시키지 않고 complete event를 발생시키는 경우는 memory leak이 발생할까? complete 시키면 자동으로 해제를 시킬까?
  >
  > - 핵심을 놓쳤다. error, complete event가 발생하면 dispose가 호출된다. (해제가 된다는 말)



## 6️⃣ Creating observable factories

subscriber에 생성되는 observable을 자동으로 구독시킬 수 있는 공장을 만들 수 있다.

- deffered operator를 사용하기
- 이후 외부에서 subscribe를 할 때마다 해당 factory가 observable을 만들어서 subscriber에게 전달한다.

``` swift
example(of: "deferred") {
  let disposeBag = DisposeBag()

  // 1
  var flip = false

  // 2
  let factory: Observable<Int> = Observable.deferred {
		// 3
    flip.toggle()

    // 4
    if flip {
      return Observable.of(1, 2, 3)
    } else {
      return Observable.of(4, 5, 6)
    }
  }
  
  for _ in 0...3 {
  	factory.subscribe(onNext: {
    	print($0, terminator: "")
  	})
  	.disposed(by: disposeBag)
		print()
	}
}
```

``` swift
--- Example of: deferred ---
123
456
123
456
```



## 7️⃣ Using Traits

Traits는 Observable보다 활동이 적은 Observable이다. 사용하는 것은 선택사항이며 Observable 대신에 사용 가능하다.

- Traits의 목적은 subcriber들에게 코드의 의도를 명확하게 전달하는 것이다.

### 3가지 종류의 Traits

**Single**

.success(value) 혹은 .error event를 발생시킨다.

- .success는 .next(value) 그리고 .completed 이벤트가 합져친 결과물
- 따라서 한번만 사용되는 프로세스에 사용하기 좋음 (ex. 다운로드 ,로딩 등)

**Completable**

.completed 또는 .error event를 발생시킨다.

- 따라서 단순히 실행이 제대로 되었는지 혹은 실패했는지 알고 싶을 때, 유용하게 사용 가능

**Maybe**

Single과 Completable의 조합

- .success(value), .completed, .error를 모두 발생시킬 수 있음
- 성공 및 실패의 가능성이 있으며, 성공 또한 값이 있을지 없을지 불확실한 경우 사용



## 8️⃣ Challenge

### 1) do operator

Observable의 method이며 Observable을 그대로 리턴한다. subsribe 전 do operator안의 클로저들이 먼저 실행되며 subscribe에 아무런 영향을 미치지 않는다.

특히 onSubscribe 등 subscribe에 없는 클로저도 있으므로 참고할 것

``` swift
someObservable.do(onNext: {
  print($0)
}).subscribe { event in 
	print(event)
}
```

### 2) debug operator

Side effects를 발생시키는 것도 rx를 디버깅 하는데 좋지만, debug operator가 더욱 유용할 수 있다.

Observable의 메서드이자 모든 이벤트를 알려줄 것이다.

``` swift
020-01-27 00:24:02.196: RxSwiftPlayground.playground:64 (__lldb_expr_3) -> subscribed
2020-01-27 00:24:02.197: RxSwiftPlayground.playground:64 (__lldb_expr_3) -> Event completed
Completed
2020-01-27 00:24:02.197: RxSwiftPlayground.playground:64 (__lldb_expr_3) -> isDisposed
```

