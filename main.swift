// Proving 2x2 = 4 without numbers

indirect enum set: Equatable {
  case empty
  case notEmpty(element: set, rest: set = .empty)

  static func == (lhs: set, rhs: set) -> Bool {
    switch (lhs, rhs) {
    case (.empty, .empty): return true
    case (_, .empty): return false
    case (.empty, _): return false
    case (.notEmpty(let x, _), .notEmpty(let y, _)):
      return y ∈ lhs && x ∈ rhs
    }
  }
}

infix operator ∈: AdditionPrecedence

func ∈(_ element: set, _ s: set) -> Bool {
  switch s {
  case .empty: return false
  case .notEmpty(let x, let xs):
    if element == x { return true }
    return element ∈ xs
  }
}

// test equals
do {
  assert(set.empty == set.empty)
  assert(set.notEmpty(element: .empty) == set.notEmpty(element: .empty))
}

// order is not important
do {
  // a = { {} {} }
  let a = set.notEmpty(element: .empty, rest: .notEmpty(element: .empty))
  assert(set.empty ∈ a)
  // b = { {} {} {} }
  let b = set.notEmpty(element: .empty, rest: .notEmpty(element: .empty, rest: .notEmpty(element: .empty)))
  // c = { a b }
  let c = set.notEmpty(element: a, rest: .notEmpty(element: b))
  // d = { b a }
  let d = set.notEmpty(element: b, rest: .notEmpty(element: a))
  assert(c == d)
}

// union of sets

infix operator ∪: AdditionPrecedence

func ∪(_ x: set, _ y: set) -> set {
  switch (x, y) {
  case (.empty, .empty): return .empty
  case (let x, .empty): return x
  case (.empty, let y): return y
  case (.notEmpty(let x, let xs), .notEmpty(let y, let ys)):
    if x == y {
      return .notEmpty(element: x, rest: xs ∪ ys)
    }
    return .notEmpty(element: x, rest: .notEmpty(element: y, rest: xs ∪ ys))
  }
}

do {
  // a = { {} }
  // b = { {} {} }
  // a ∪ b = { {} {} }
  let a = set.notEmpty(element: .empty)
  let b = set.notEmpty(element: .empty, rest: .notEmpty(element: .empty))
  assert(a ∪ b == b)
}

// count for debug
extension set {
  var count: Int {
    switch self {
    case .empty: return 0
    case .notEmpty(_, let rest): return 1 + rest.count
    }
  }
}

// Von Neumann Ordinals

// successor
// S(n) = n ∪ {n}

func s(_ n: set) -> set {
  n ∪ .notEmpty(element: n)
}

do {
  let zero = set.empty
  let one = set.notEmpty(element: .empty)
  assert(s(zero) == one)
  assert(zero.count == 0)
  assert(one.count == 1)
  assert(s(one).count == 2)
}

// Addition

infix operator +: AdditionPrecedence

func + (_ a: set, _ b: set) -> set {
  // a + 0 = a
  // a + s(b) = s(a + b)
  switch b {
  case .empty: return a
  case .notEmpty(_, let p):
    return s(a + p)
  }
}

do {
  let zero = set.empty
  let one = s(zero)
  let two = s(one)
  assert(zero + zero == zero)
  assert(one + zero == one)
  assert(zero + one == one)
  assert(one + one == two)
  assert(two == one + zero + one)
}

// Multiplication

infix operator *: MultiplicationPrecedence

func * (_ a: set, _ b: set) -> set {
  // a * 0 = 0
  // a * s(b) = a + (a * b)
  switch b {
  case .empty: return .empty
  case .notEmpty(_, let p):
    return a + (a * p)
  }
}

do {
  let zero = set.empty
  let one = s(zero)
  let two = s(one)
  let three = s(two)
  let four = s(three)
  let five = s(four)
  assert(zero * zero == zero)
  assert(zero * two == zero)
  assert(two * zero == zero)
  assert(one * one == one)
  assert(one * two == two)
  assert(two * two == four)
  // test associativity
  // x(yz) = (xy)z
  assert(three * (two * one) == (three * two) * one)
  assert(three * (four * five) == (three * four) * five)

  // print out the number as Int
  // 3 4 4 = 48
  print((three * four * four).count == 48)
}

do {
  // multiplication distributes over addition
  // x (y + z) = (xy) + (xz)
  let zero = set.empty
  let one = s(zero)
  let two = s(one)
  let three = s(two)
  let four = s(three)

  assert(three * (two + four) == (three * two) + (three * four))
}
