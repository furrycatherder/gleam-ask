import ask/eq
import ask/ord
import ask/predicate.{always, never}
import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/order
import gleam/string
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

/// Put whatever here...
const a = 0

pub fn predicate_and_test() {
  predicate.and(never(), never())(a)
  |> should.equal(False)

  predicate.and(never(), always())(a)
  |> should.equal(False)

  predicate.and(always(), never())(a)
  |> should.equal(False)

  predicate.and(always(), always())(a)
  |> should.equal(True)
}

pub fn predicate_or_test() {
  predicate.or(never(), never())(a)
  |> should.equal(False)

  predicate.or(never(), always())(a)
  |> should.equal(True)

  predicate.or(always(), never())(a)
  |> should.equal(True)

  predicate.or(always(), always())(a)
  |> should.equal(True)
}

pub fn predicate_not_test() {
  predicate.negate(always())(a)
  |> should.equal(False)

  predicate.negate(never())(a)
  |> should.equal(True)
}

pub fn predicate_every_test() {
  predicate.every([])(a)
  |> should.equal(True)

  predicate.every([always()])(a)
  |> should.equal(True)

  predicate.every([never()])(a)
  |> should.equal(False)

  predicate.every([always(), always()])(a)
  |> should.equal(True)

  predicate.every([always(), never()])(a)
  |> should.equal(False)

  predicate.every([never(), always()])(a)
  |> should.equal(False)

  predicate.every([never(), never()])(a)
  |> should.equal(False)
}

pub fn predicate_some_test() {
  predicate.some([])(a)
  |> should.equal(False)

  predicate.some([always()])(a)
  |> should.equal(True)

  predicate.some([never()])(a)
  |> should.equal(False)

  predicate.some([always(), always()])(a)
  |> should.equal(True)

  predicate.some([always(), never()])(a)
  |> should.equal(True)

  predicate.some([never(), always()])(a)
  |> should.equal(True)

  predicate.some([never(), never()])(a)
  |> should.equal(False)
}

pub fn predicate_all_test() {
  predicate.all(never())([])
  |> should.equal(True)

  predicate.all(never())([a])
  |> should.equal(False)

  predicate.all(always())([])
  |> should.equal(True)

  predicate.all(always())([a])
  |> should.equal(True)
}

pub fn predicate_any_test() {
  predicate.any(never())([])
  |> should.equal(False)

  predicate.any(never())([a])
  |> should.equal(False)

  predicate.any(always())([])
  |> should.equal(False)

  predicate.any(always())([a])
  |> should.equal(True)
}

pub fn predicate_map_input_test() {
  predicate.map_input(always(), fn(_) { False })(a)
  |> should.equal(True)

  predicate.map_input(always(), fn(_) { True })(a)
  |> should.equal(True)

  predicate.map_input(never(), fn(_) { False })(a)
  |> should.equal(False)

  predicate.map_input(never(), fn(_) { True })(a)
  |> should.equal(False)

  predicate.map_input(int.is_even, string.length)("hello")
  |> should.equal(False)

  predicate.map_input(int.is_even, string.length)("world!")
  |> should.equal(True)
}

pub fn eq_trivial_test() {
  eq.trivial()(1, 1)
  |> should.equal(True)

  eq.trivial()(1, 2)
  |> should.equal(True)
}

pub fn eq_and_test() {
  let eq1 = fn(a, b) { a == b }
  let eq2 = fn(a, b) { a % 2 == b % 2 }
  let and_eq = eq.and(eq1, eq2)

  and_eq(2, 2)
  |> should.equal(True)

  and_eq(3, 3)
  |> should.equal(True)

  and_eq(2, 3)
  |> should.equal(False)
}

pub fn eq_or_test() {
  let eq1 = fn(a, b) { a == b }
  let eq2 = fn(a, b) { a % 2 == b % 2 }
  let or_eq = eq.or(eq1, eq2)

  or_eq(2, 2)
  |> should.equal(True)

  or_eq(3, 3)
  |> should.equal(True)

  or_eq(2, 4)
  |> should.equal(True)

  or_eq(3, 6)
  |> should.equal(False)

  or_eq(1, 2)
  |> should.equal(False)
}

pub fn eq_not_test() {
  let eq = fn(a, b) { a == b }
  let not_eq = eq.negate(eq)

  not_eq(1, 1)
  |> should.equal(False)

  not_eq(1, 2)
  |> should.equal(True)
}

pub fn eq_list_test() {
  let eq = fn(a, b) { a == b }
  let all_eq = eq.list(eq)

  all_eq([1, 1, 1], [1, 1, 1])
  |> should.equal(True)

  all_eq([1, 1, 1], [1, 1, 2])
  |> should.equal(False)

  all_eq([1, 1, 1], [1, 1])
  |> should.equal(False)
}

pub fn eq_pair_test() {
  let eq = fn(a, b) { a == b }
  let pair_eq = eq.pair(eq, eq)

  pair_eq(#(1, 1), #(1, 1))
  |> should.equal(True)

  pair_eq(#(1, 1), #(1, 2))
  |> should.equal(False)
}

pub fn eq_map_input_test() {
  let eq = fn(a, b) { a == b }
  let map_eq = eq.map_input(eq, fn(x) { x % 2 })

  map_eq(1, 1)
  |> should.equal(True)

  map_eq(2, 4)
  |> should.equal(True)

  map_eq(3, 5)
  |> should.equal(True)

  map_eq(1, 2)
  |> should.equal(False)
}

pub fn eq_contains_test() {
  let eq = fn(a, b) { a % 2 == b % 2 }
  let contains_eq = eq.contains(eq)

  contains_eq([2, 2, 2], 2)
  |> should.equal(True)

  contains_eq([2, 2, 2], 3)
  |> should.equal(False)

  contains_eq([2, 2, 2], 4)
  |> should.equal(True)

  contains_eq([1, 3, 5], 1)
  |> should.equal(True)

  contains_eq([1, 3, 5], 2)
  |> should.equal(False)

  contains_eq([1, 3, 5], 3)
  |> should.equal(True)
}

pub fn eq_unique_test() {
  let eq = fn(a, b) { a % 2 == b % 2 }
  let unique_eq = eq.unique(eq)

  unique_eq([1, 2, 3])
  |> should.equal([1, 2])

  unique_eq([1, 1, 1])
  |> should.equal([1])

  unique_eq([1, 3, 5])
  |> should.equal([1])

  unique_eq([2, 4, 6])
  |> should.equal([2])
}

pub fn ord_trivial_test() {
  let ord = ord.trivial()

  list.sort([1, 2, 3], ord)
  |> should.equal([1, 2, 3])

  list.sort([3, 2, 1], ord)
  |> should.equal([3, 2, 1])
}

pub fn ord_combine_test() {
  let ord1 = fn(a, b) { int.compare(a % 2, b % 2) }
  let ord2 = fn(a, b) { int.compare(b, a) }

  list.sort([1, 2, 3, 4, 5, 6], ord.combine(ord1, ord2))
  |> should.equal([6, 4, 2, 5, 3, 1])
}

pub fn ord_between_test() {
  let is_digit = ord.between(int.compare, 0, 10)

  is_digit(0)
  |> should.equal(True)

  is_digit(5)
  |> should.equal(True)

  is_digit(10)
  |> should.equal(False)
}

pub fn ord_clamp_test() {
  let clamp = ord.clamp(int.compare, 0, 10)

  clamp(0)
  |> should.equal(0)

  clamp(5)
  |> should.equal(5)

  clamp(10)
  |> should.equal(10)

  clamp(-1)
  |> should.equal(0)

  clamp(11)
  |> should.equal(10)
}

pub fn ord_pair_test() {
  let pair_ord = ord.pair(int.compare, int.compare)

  pair_ord(#(1, 1), #(1, 1))
  |> should.equal(order.Eq)

  pair_ord(#(1, 1), #(1, 2))
  |> should.equal(order.Lt)

  pair_ord(#(1, 2), #(1, 1))
  |> should.equal(order.Gt)
}

pub fn ord_map_input_test() {
  let ord = ord.map_input(int.compare, fn(x) { x % 2 })

  ord(1, 1)
  |> should.equal(order.Eq)

  ord(2, 4)
  |> should.equal(order.Eq)

  ord(3, 5)
  |> should.equal(order.Eq)

  ord(1, 2)
  |> should.equal(order.Gt)
}

pub fn ord_optional_test() {
  let compare = ord.optional(int.compare)

  compare(None, None)
  |> should.equal(order.Eq)

  compare(None, Some(1))
  |> should.equal(order.Lt)

  compare(Some(1), None)
  |> should.equal(order.Gt)

  compare(Some(1), Some(1))
  |> should.equal(order.Eq)

  compare(Some(1), Some(2))
  |> should.equal(order.Lt)

  compare(Some(2), Some(1))
  |> should.equal(order.Gt)
}
