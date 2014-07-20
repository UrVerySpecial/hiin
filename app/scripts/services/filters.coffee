'use strict';

angular.module("filters", [])
.filter "gender", ->
  (input) ->
    (if input == '1' then "Female" else "Male")
.filter "getUserById", ->
  (input, id) ->
    i = 0
    len = input.length
    while i < len
      return input[i]  if input[i]._id is id
      i++
    null