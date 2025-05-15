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

ask_number_words() {
    read -r -p "How many words you want? " number_words

    while ! echo "$number_words" | grep -q "^[0-9][0-9]*$"; do
        read -r -p "A NUMBER, PLEASE." number_words
    done

    echo "$number_words"
}

gen_pass_words() {
    array_words=()
    wordlength=$(ask_number_words)
    length=($(seq 1 "$wordlength"))

    for i in "${length[@]}"; do
        word=$(get_word)

        # separate array items
        #test_array+=("${word@u}")

        # one single array item
        array_words+="${word@u}"
    done

    #echo "${array_words[@]}"
}

#####################################################################

# this function will generate a random number between 0 and 9
get_rng_number() {
    shuf -n 1 -i 0-9
}

ask_number_numbers() {
    read -r -p "How many numbers you want? " number_numbers

    while ! echo "$number_numbers" | grep -q "^[0-9][0-9]*$"; do
        read -r -p "A NUMBER, PLEASE." number_numbers
    done

    echo "$number_numbers"
}

gen_pass_numbers() {
    array_numbers=()
    numlength=$(ask_number_numbers)
    length=($(seq 1 "$numlength"))

    for i in "${length[@]}"; do
        number=$(get_rng_number)

        # separate array items
        #array_numbers+=("${number}")

        # one single array item
        array_numbers+="${number}"
    done

    #echo "${array_numbers[@]}"
}

#####################################################################

gen_pass_words

gen_pass_numbers

echo "${array_words}${array_numbers}"
