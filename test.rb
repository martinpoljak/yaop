# encoding: utf-8
$:.push(".")
require "./lib/yaop"

options = YAOP::get do
    option "--strip"

    options "-l", "--level"   # both of them
    type Integer, 7           # first part, default value 7
    type Integer, 8           # second part, default value 8
    type Integer, 9           # third part, default value 9
end

p options
