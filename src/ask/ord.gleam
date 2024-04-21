import gleam/bool
import gleam/order

pub type Ord(a) =
  fn(a, a) -> order.Order

/// Create a new ordering that always returns `order.Eq`.
///
pub fn trivial() -> Ord(a) {
  fn(_, _) -> order.Order { order.Eq }
}

/// Every law-abiding ordering is also an equivalence.
///
pub fn get_equivalence(ord: Ord(a)) {
  fn(value: a, other: a) { value == other || ord(value, other) == order.Eq }
}

/// Reverse the order of an ordering.
///
pub fn reverse(ord: Ord(a)) -> Ord(a) {
  fn(value: a, other: a) { ord(other, value) }
}

/// Combine two orderings into a new ordering, which will order by the first,
/// then by the second in case of a tie.
///
pub fn combine(first: Ord(a), second: Ord(a)) {
  fn(value: a, other: a) {
    first(value, other)
    |> order.lazy_break_tie(with: fn() { second(value, other) })
  }
}

/// Test whether a value is between two others, according to a given ordering.
///
pub fn between(ord: Ord(a), lower: a, upper: a) {
  fn(value: a) {
    ord(lower, value) == order.Lt && ord(value, upper) == order.Lt
  }
}

/// Clamp a value to a given range, according to a given ordering.
///
pub fn clamp(ord: Ord(a), lower: a, upper: a) {
  fn(value: a) {
    use <- bool.guard(when: ord(value, lower) == order.Lt, return: lower)
    use <- bool.guard(when: ord(value, upper) == order.Gt, return: upper)
    value
  }
}

/// Create a new ordering for a pair of values based on the given orderings.
///
pub fn pair(first: Ord(a), second: Ord(b)) -> Ord(#(a, b)) {
  fn(value: #(a, b), other: #(a, b)) {
    first(value.0, other.0)
    |> order.lazy_break_tie(with: fn() { second(value.1, other.1) })
  }
}
