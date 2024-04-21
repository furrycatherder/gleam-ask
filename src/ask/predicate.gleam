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
pub fn negate(p: Predicate(a)) -> Predicate(a) {
  fn(value: a) -> Bool { !p(value) }
}

fn do_every(ps: List(Predicate(a)), value: a, acc: Bool) -> Bool {
  case ps {
    [] -> acc
    [p, ..ps] -> do_every(ps, value, acc && p(value))
  }
}

/// Combine a list of predicates together into a new predicate that returns `True`
/// if all predicates return `True`.
///
pub fn every(ps: List(Predicate(a))) -> Predicate(a) {
  fn(value: a) -> Bool { do_every(ps, value, True) }
}

fn do_some(ps: List(Predicate(a)), value: a, acc: Bool) -> Bool {
  case ps {
    [] -> acc
    [p, ..ps] -> do_some(ps, value, acc || p(value))
  }
}

/// Combine a list of predicates together into a new predicate that returns `True`
/// if any predicate returns `True`.
///
pub fn some(ps: List(Predicate(a))) -> Predicate(a) {
  fn(value: a) -> Bool { do_some(ps, value, False) }
}

/// Create a new predicate that returns `True` if the given predicate returns
/// `True` for every element in a list.
///
pub fn all(p: Predicate(a)) -> Predicate(List(a)) {
  fn(a: List(a)) -> Bool { list.all(a, p) }
}

/// Create a new predicate that returns `True` if the given predicate returns
/// `True` for any element in a list.
///
pub fn any(p: Predicate(a)) -> Predicate(List(a)) {
  fn(a: List(a)) -> Bool { list.any(a, p) }
}

/// Map the input of a predicate to create a new predicate.
///
pub fn map_input(over p: Predicate(a), with fun: fn(b) -> a) -> Predicate(b) {
  fn(b: b) -> Bool { p(fun(b)) }
}
