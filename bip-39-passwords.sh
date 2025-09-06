#!/bin/sh

wordlist="wordlist.txt"
checksum="2f5eed53a4727b4bf8880d8f3f199efc90e58503646d9ff8eff3a2ed3b24dbda"
tmpdir="/tmp/bip-39-passwords"
tmpfile="${tmpdir}/${wordlist}"
url_seedwords="https://raw.githubusercontent.com/bitcoin/bips/refs/heads/master/bip-0039/english.txt"

#####################################################################

verify_checksum() {
    local hash="$(sha256sum $1)"
    hash="${hash%% *}"

    [[ "$checksum" == "$hash" ]]
}

# prints argument to STDERR and exits
error() {
    echo "$1" >&2 \
        && exit 1
}

# Prefer the repo's `wordlist.txt`
# If no local `wordlist.txt`, use one in `/tmp/bip-39-passwords`
# Download from official Bitcoin repo if necessary
get_wordlist() {
    if [[ -f "$wordlist" ]] && verify_checksum "$wordlist"; then
        return 0
    fi

    echo "[WARN]: \`${wordlist}\` not found, or invalid. Now checking \`${tmpfile}\`."

    if [[ ! -f ${tmpfile} ]]; then
        echo "[WARN]: \`${tmpfile}\` not found. Attempting to download now..."
        mkdir -p "$tmpdir"
        curl -s "$url_seedwords" > "$tmpfile" \
            || error "[ERROR]: Unable to download a copy of the wordlist. Exiting now."
    fi

    wordlist="$tmpfile"

    if ! verify_checksum "$wordlist"; then
        error "[ERROR]: No valid wordlist. Exiting now."
    fi

    return 0
}

# Takes in a range (ex. "1-100"), outputs random number within range
get_rng() {
    shuf -n 1 -i $1
}

#####################################################################

ask_wordcount() {
    read -r -p "How many words do you want in the password? " wordcount

    while ! echo "$wordcount" | grep -q "^[0-9][0-9]*$"; do
        read -r -p "A NUMBER, PLEASE." wordcount
    done

    echo "$wordcount"
}

# this functions populates `arr_words` with words
gen_arr_words() {
    arr_words=()
    wordcount="$(ask_wordcount)"

    for ((i = 0; i < "$wordcount"; i++)); do
        rand=$(get_rng "1-2048")
        word=$(sed -n "${rand}"p "$wordlist")
        arr_words+="${word@u}"
    done
}

#####################################################################

ask_numcount() {
    read -r -p "How many numbers do you want in the password? " numcount

    while ! echo "$numcount" | grep -q "^[0-9][0-9]*$"; do
        read -r -p "A NUMBER, PLEASE." numcount
    done

    echo "$numcount"
}

# this function populates `array_nums` with numbers
gen_arr_nums() {
    arr_nums=()
    numlength=$(ask_numcount)

    for ((i = 0; i < "$numlength"; i++)); do
        num=$(get_rng "0-9")
        arr_nums+="${num}"
    done
}

#####################################################################

main() {
    get_wordlist
    gen_arr_words
    gen_arr_nums
    echo "${arr_words}${arr_nums}"
}

main
