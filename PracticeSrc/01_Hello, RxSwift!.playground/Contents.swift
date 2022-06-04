import UIKit

// Synchronous code
var array = [1, 2, 3]
for number in array {
  print(number)
  array = [4, 5, 6]
}
print(array)
/*
 1
 2
 3
 [4, 5, 6]
 */
/// 컬렉션에 접근해 for문을 반복 실행하는 것은
/// 동기적으로 실행되고 컬렉션을 반복하는 동안 immutable하기 때문에
/// 이와 같은 출력이 나온다.

// Asynchronous code
var array2 = [1, 2, 3]
var currentIndex = 0

// This method is connected in Interface Builder to a button
@IBAction private func printNext() {
  print(array[currentIndex])

  if currentIndex != array.count - 1 {
    currentIndex += 1
  }
}
// 버튼 탭에 대한 반응으로 비슷한 구문을 반복하는 코드
// 사용자가 배열의 마지막 원소까지 다 누른다는 보장이 없기 때문에,
// 배열이 다 출력 되기 전, 다른 비동기 코드로 컬렉션에 접근하여 삽입/삭제가 가능해진다.
// currentIndex도 다른 코드 구문에 의해 값 수정이 발생할 수 있다.

