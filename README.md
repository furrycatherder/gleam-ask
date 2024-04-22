# ask

[![Package Version](https://img.shields.io/hexpm/v/ask)](https://hex.pm/packages/ask)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/ask/)
![CI](https://github.com/furrycatherder/gleam-ask/actions/workflows/tests.yml/badge.svg?branch=main)

`ask` is a Gleam library tailored for simplifying the management of
equivalences, orderings, and predicates. Equivalences allow for the comparison
of two values to determine if they're equivalent, while orderings provide a
systematic way to compare values in terms of their relative magnitudes or
positions. Predicates, on the other hand, assess if a given value meets
specific conditions, offering a flexible mechanism for expressing logical
constraints or requirements.

## Overview

`ask` provides developers with a set of functions to create, combine, and
transform equivalences, orderings, and predicates. Whether you're performing
basic value comparisons or intricate logical operations, `ask` furnishes the
necessary tools to handle a variety of scenarios effectively.

## Installation

```sh
gleam add ask
```

## Usage

### Equivalences

```gleam
import ask/eq

// Defining custom equivalences
let eq1 = fn(x, y) { x % 3 == y % 3 }
let eq2 = fn(x, y) { x % 5 == y % 5 }

// Combining equivalences using logical operations
let combined_eq = eq.and(eq1, eq2)

// Using equivalence to compare values
let result = combined_eq(15, 30) // Returns True
```

Equivalences are expected to follow these friendly rules:

- **Reflexivity**: Every value is equivalent to itself. It's like saying, "Hey,
  you're always equal to yourself!"
- **Symmetry**: If one value is equivalent to another, then it's a two-way
  street! If X is like Y, then Y is like X. It's all about fairness!
- **Transitivity**: Imagine a chain of equivalence! If X is equivalent to Y,
  and Y is equivalent to Z, then it's like saying X is also buddies with Z.
  Friendship circles all around!

These rules help keep our equivalences reliable and predictable, making sure
they play nice with each other.

### Orderings

```gleam
import ask/ord
import gleam/int
import gleam/list
import gleam/string

type User {
  User(name: String, age: Int)
}

let compare_name = ord.map_input(string.compare, fn(user: User) { user.name })
let compare_age = ord.map_input(int.compare, fn(user: User) { user.age })

// Sort by name, then by age
let compare_user = ord.combine(compare_name, compare_age)
let result =
  list.sort(
    [
      User(name: "alice", age: 32),
      User(name: "bob", age: 45),
      User(name: "alice", age: 24),
    ],
    by: compare_user,
  )
```

### Predicates

```gleam
import ask/predicate

// Defining custom predicates
let is_positive = fn(x) { x > 0 }
let is_even = fn(x) { x % 2 == 0 }

// Combining predicates using logical operations
let combined_pred = predicate.and(is_positive, is_even)

// Using predicate to evaluate values
let result = combined_pred(6) // Returns True
let result = combined_pred(-6) // Returns False
```

## Conclusion

`ask` equips Gleam developers with a robust toolkit for managing equivalences,
orderings, and predicates efficiently. Whether you're implementing algorithms,
data validation systems, or decision-making processes, `ask` facilitates
streamlined code development, allowing you to focus on problem-solving.

Further documentation can be found at <https://hexdocs.pm/ask>.

## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests
gleam shell # Run an Erlang shell
```
