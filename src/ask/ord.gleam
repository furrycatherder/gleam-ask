import gleam/bool
import gleam/option
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
/// The provided interval is half-open, `[lower, upper)`, i.e. greater than or
/// equal to lower and less than upper.
pub fn between(ord: Ord(a), lower: a, upper: a) {
  fn(value: a) {
    ord(lower, value) != order.Gt && ord(value, upper) == order.Lt
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

/// Map the input of an ordering to create a new ordering.
///
pub fn map_input(over ord: Ord(b), with fun: fn(a) -> b) -> Ord(a) {
  fn(value: a, other: a) { ord(fun(value), fun(other)) }
}

/// Create a new order that sorts optional values based on the given ordering.
///
/// A `None` value is always considered less than a `Some` value.
pub fn optional(ord: Ord(a)) {
  fn(value: option.Option(a), other: option.Option(a)) {
    case value, other {
      option.Some(value), option.Some(other) -> ord(value, other)
      option.Some(_), option.None -> order.Gt
      option.None, option.Some(_) -> order.Lt
      option.None, option.None -> order.Eq
    }
  }
}
