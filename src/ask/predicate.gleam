import gleam/list

pub type Predicate(a) =
  fn(a) -> Bool

/// Create a new predicate that always returns `True`.
///
pub fn always() -> Predicate(a) {
  fn(_) -> Bool { True }
}

/// Create a new predicate that always returns `False`.
///
pub fn never() -> Predicate(a) {
  fn(_) -> Bool { False }
}

/// Combine two predicates together into a new predicate that returns `True` if
/// both predicates return `True`.
///
pub fn and(first: Predicate(a), second: Predicate(a)) -> Predicate(a) {
  fn(value: a) -> Bool { first(value) && second(value) }
}

/// Combine two predicates together into a new predicate that returns `True` if
/// either predicate returns `True`.
///
pub fn or(first: Predicate(a), second: Predicate(a)) -> Predicate(a) {
  fn(value: a) -> Bool { first(value) || second(value) }
}

/// Negate a predicate.
///
pub fn not(p: Predicate(a)) -> Predicate(a) {
  fn(value: a) -> Bool { !p(value) }
}

/// Combine a list of predicates together into a new predicate that returns `True`
/// if all predicates return `True`.
///
pub fn every(ps: List(Predicate(a))) -> Predicate(a) {
  case ps {
    [] -> fn(_) -> Bool { True }
    [p, ..ps] -> fn(value: a) -> Bool { p(value) && every(ps)(value) }
  }
}

/// Combine a list of predicates together into a new predicate that returns `True`
/// if any predicate returns `True`.
///
pub fn some(ps: List(Predicate(a))) -> Predicate(a) {
  case ps {
    [] -> fn(_) -> Bool { False }
    [p, ..ps] -> fn(value: a) -> Bool { p(value) || some(ps)(value) }
  }
}

/// Create a new predicate that returns `True` if it returns `True` for every
/// element in a list.
///
pub fn all(p: Predicate(a)) -> Predicate(List(a)) {
  fn(a: List(a)) -> Bool {
    a
    |> list.all(p)
  }
}

/// Create a new predicate that returns `True` if it returns `True` for any
/// element in a list.
///
pub fn any(p: Predicate(a)) -> Predicate(List(a)) {
  fn(a: List(a)) -> Bool {
    a
    |> list.any(p)
  }
}

/// Map the input of a predicate to create a new predicate.
///
pub fn map_input(over p: Predicate(a), with fun: fn(b) -> a) -> Predicate(b) {
  fn(b: b) -> Bool { p(fun(b)) }
}
