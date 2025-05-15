#!/bin/sh

#####################################################################

# this function will generate a random number between 0 and 2047
get_rng_word() {
    shuf -n 1 -i 0-2047
}

# this function generates a random number
# then, the function looks up the word at that number
get_word() {
    number=$(get_rng_word)

    sed -n "${number}"p wordlist.txt
}

#####################################################################

test_arr=()

test_arr+=("$(get_word)")
test_arr+=("$(get_word)")
test_arr+=("$(get_word)")

echo "my test array: ${test_arr[@]}"

#####################################################################
