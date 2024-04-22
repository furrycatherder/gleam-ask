import gleam/bool
import gleam/list

pub type Equivalence(a) =
  fn(a, a) -> Bool

/// Create a new equivalence that always returns `True`.
///
/// This is sometimes called the trivial or universal equivalence.
///
pub fn trivial() -> Equivalence(a) {
  fn(_, _) -> Bool { True }
}

/// Create a new equivalence that uses the default equality comparison.
///
pub fn default() -> Equivalence(a) {
  fn(value: a, other: a) -> Bool { value == other }
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
pub fn negate(eq: Equivalence(a)) -> Equivalence(a) {
  fn(value: a, other: a) -> Bool { !eq(value, other) }
}

fn do_list(
  eq: Equivalence(a),
  values: List(a),
  others: List(a),
  acc: Bool,
) -> Bool {
  case values, others {
    [], [] -> acc
    [value, ..values], [other, ..others] -> {
      do_list(eq, values, others, acc && eq(value, other))
    }
    _, _ -> False
  }
}

/// Create a new equivalence for a list of values based on the given equivalence.
///
pub fn list(eq: Equivalence(a)) -> Equivalence(List(a)) {
  fn(values: List(a), others: List(a)) -> Bool {
    use <- bool.guard(
      when: list.length(values) != list.length(others),
      return: False,
    )

    do_list(eq, values, others, True)
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
/// ## Examples
///
/// This can be useful for constructing a custom equivalence of a record, given
/// that we have an equivalence for one or more of its fields.
///
/// ```gleam
/// import ask/equivalence as eq
///
/// type User {
///   User(name: String, age: Int)
/// }
///
/// pub fn main() {
///   let user1 = User("alice", 30)
///   let user2 = User("alice", 24)
///   let is_username_equal =
///     eq.default()
///     |> eq.map_input(fn(user: User) { user.name })
///
///   is_username_equal(user1, user2) // -> True
/// }
/// ```
///
pub fn map_input(
  over eq: Equivalence(a),
  with fun: fn(b) -> a,
) -> Equivalence(b) {
  fn(value: b, other: b) -> Bool { eq(fun(value), fun(other)) }
}

fn do_contains(eq: Equivalence(a), list: List(a), elem: a, acc: Bool) {
  case list {
    [] -> acc
    [x, ..xs] -> do_contains(eq, xs, elem, acc || eq(x, elem))
  }
}

/// Test if a value is a member of a list according to the given equivalence.
///
pub fn contains(eq: Equivalence(a)) {
  fn(list: List(a), elem: a) { do_contains(eq, list, elem, False) }
}

fn do_unique(eq: Equivalence(a), list: List(a), acc: List(a)) {
  case list {
    [] -> list.reverse(acc)
    [x, ..xs] ->
      do_unique(
        eq,
        xs,
        bool.guard(when: contains(eq)(acc, x), return: acc, otherwise: fn() {
          [x, ..acc]
        }),
      )
  }
}

/// Remove duplicates from a list, keeping the first occurrence of each element
/// according to the given equivalence.
///
pub fn unique(eq: Equivalence(a)) {
  fn(list: List(a)) { do_unique(eq, list, []) }
}
