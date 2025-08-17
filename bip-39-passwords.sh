#!/bin/sh

#####################################################################

# this functions grabs the wordlist
# prefers the `wordlist.txt` local to the repo
# if that doesn't exist, check the `/tmp` directory
# if that doesn't exist, grab the wordlist from GitHub
get_wordlist() {
    if [[ -z wordlist.txt ]]; then
        if [[ -z /tmp/bip-39-passwords/wordlist.txt ]]; then
            mkdir -p /tmp/bip-39-passwords
            curl https://raw.githubusercontent.com/bitcoin/bips/refs/heads/master/bip-0039/english.txt > /tmp/bip-39-passwords/wordlist.txt
        fi

        wordlist="/tmp/bip-39-passwords/wordlist.txt"
    else
        wordlist="wordlist.txt"
    fi
}

# this function will get some randomness
# `$1` is the range (ex. 1-100)
get_rng() {
    shuf -n 1 -i $1
}

#####################################################################

ask_number_words() {
    read -r -p "How many words you want? " number_words

    while ! echo "$number_words" | grep -q "^[0-9][0-9]*$"; do
        read -r -p "A NUMBER, PLEASE." number_words
    done

    echo "$number_words"
}

# this function gets a random number between 1 and 2048
# then, the function looks up the word at that value
get_word() {
    number=$(get_rng "1-2048")

    sed -n "${number}"p "$wordlist"
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
        number=$(get_rng "0-9")

        # separate array items
        #array_numbers+=("${number}")

        # one single array item
        array_numbers+="${number}"
    done

    #echo "${array_numbers[@]}"
}

#####################################################################

main() {
    get_wordlist

    gen_pass_words

    gen_pass_numbers

    echo "${array_words}${array_numbers}"
}

main
