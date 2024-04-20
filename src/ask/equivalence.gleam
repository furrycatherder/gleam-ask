pub type Equivalence(a) =
  fn(a, a) -> Bool

/// Create a new equivalence that always returns `True`.
///
/// This is sometimes called the trivial or universal equivalence.
///
pub fn trivial() -> Equivalence(a) {
  fn(_, _) -> Bool { True }
}

/// Combine two equivalences into a new equivalence that returns `True` if both
/// equivalences return `True`.
///
pub fn and(first: Equivalence(a), second: Equivalence(a)) -> Equivalence(a) {
  fn(value: a, other: a) -> Bool { first(value, other) && second(value, other) }
}

/// Combine two equivalences into a new equivalence that returns `True` if either
/// equivalence returns `True`.
///
pub fn or(first: Equivalence(a), second: Equivalence(a)) -> Equivalence(a) {
  fn(value: a, other: a) -> Bool { first(value, other) || second(value, other) }
}

/// Negate an equivalence to create a new equivalence that returns `True` if the
/// original equivalence returns `False`.
///
pub fn not(eq: Equivalence(a)) -> Equivalence(a) {
  fn(value: a, other: a) -> Bool { !eq(value, other) }
}

/// Create a new equivalence for a list of values based on the given equivalence.
///
pub fn list(eq: Equivalence(a)) -> Equivalence(List(a)) {
  fn(values: List(a), others: List(a)) -> Bool {
    case values, others {
      [], [] -> True
      [value, ..values], [other, ..others] -> {
        eq(value, other) && list(eq)(values, others)
      }
      _, _ -> False
    }
  }
}

/// Create a new equivalence for a pair of values based on the given equivalences.
///
pub fn pair(
  first: Equivalence(a),
  second: Equivalence(b),
) -> Equivalence(#(a, b)) {
  fn(value: #(a, b), other: #(a, b)) -> Bool {
    case value, other {
      #(value1, value2), #(other1, other2) -> {
        first(value1, other1) && second(value2, other2)
      }
    }
  }
}

/// Map the input of an equivalence to create a new equivalence.
///
pub fn map_input(
  over eq: Equivalence(a),
  with fun: fn(b) -> a,
) -> Equivalence(b) {
  fn(value: b, other: b) -> Bool { eq(fun(value), fun(other)) }
}
