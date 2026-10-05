params {
    step: Integer = 0
    zip: String = 'zip'
}

// Task 1
process SAYHELLO {
    debug true

    script:
    """
    echo "Hello World!"
    """
}

// Task 2
process SAYHELLO_PYTHON {
    debug true

    script:
    """
    python -c "print('Hello World!')"
    """
}

// Task 3
process SAYHELLO_PARAM {
    debug true

    input:
    val greeting

    script:
    """
    echo "$greeting"
    """
}

// Task 4
process SAYHELLO_FILE {
    debug true
    
    input:
    val greeting

    output:
    path "greeting.txt"

    script:
    """
    echo "$greeting" > greeting.txt
    """
}

// Task 5
process UPPERCASE {
    debug true
    
    input:
    val greeting

    output:
    path "uppercase.txt"

    script:
    """
    echo "$greeting" | tr '[:lower:]' '[:upper:]' > uppercase.txt
    """
}

// Task 6
process PRINTUPPER {
    debug true
    
    input:
    path input_file

    script:
    """
    cat $input_file
    """
}

// Task 7 
process ZIPFILE {

    input:
    path input_file
    val method

    output:
    path "compressed.*"

    script:
    """
    if [ "$method" = "zip" ]; then
        zip compressed.zip $input_file
    elif [ "$method" = "gzip" ]; then
        gzip -c $input_file > compressed.gz
    elif [ "$method" = "bzip2" ]; then
        bzip2 -c $input_file > compressed.bz2
    else
        echo "Unknown compression method: $method"
        exit 1
    fi
    """
}

// Task 8
process ZIPALL {
    debug true

    input:
    path input_file

    output:
    tuple path("compressed.zip"), path("compressed.gz"), path("compressed.bz2")

    script:
    """
    zip compressed.zip $input_file
    gzip -c $input_file > compressed.gz
    bzip2 -c $input_file > compressed.bz2
    """
}

// Task 9
process WRITETOFILE {
    debug true
    
    publishDir 'results', mode: 'copy'

    input:
    val entries

    output:
    path "names.tsv"

    script:
    def lines = entries.collect { "${it.name}\t${it.title}" }.join('\n')

    """
    cat > names.tsv <<EOF
${lines}
EOF
    """
}



workflow {

    // Task 1 - create a process that says Hello World! (add debug true to the process right after initializing to be sable to print the output to the console)
    if (params.step == 1) {
        SAYHELLO()
    }

    // Task 2 - create a process that says Hello World! using Python
    if (params.step == 2) {
        SAYHELLO_PYTHON()
    }

    // Task 3 - create a process that reads in the string "Hello world!" from a channel and write it to command line
    if (params.step == 3) {
        greeting_ch = Channel.of("Hello world!")
        SAYHELLO_PARAM(greeting_ch)
    }

    // Task 4 - create a process that reads in the string "Hello world!" from a channel and write it to a file. WHERE CAN YOU FIND THE FILE?
    if (params.step == 4) {
        greeting_ch = Channel.of("Hello world!")
        SAYHELLO_FILE(greeting_ch)
    }

    // Task 5 - create a process that reads in a string and converts it to uppercase and saves it to a file as output. View the path to the file in the console
    if (params.step == 5) {
        greeting_ch = Channel.of("Hello world!")
        out_ch = UPPERCASE(greeting_ch)
        out_ch.view()
    }

    // Task 6 - add another process that reads in the resulting file from UPPERCASE and print the content to the console (debug true). WHAT CHANGED IN THE OUTPUT?
    if (params.step == 6) {
        greeting_ch = Channel.of("Hello world!")
        out_ch = UPPERCASE(greeting_ch)
        PRINTUPPER(out_ch)
    }
    
    // Task 7 - based on the paramater "zip" (see at the head of the file), create a process that zips the file created in the UPPERCASE process either in "zip", "gzip" OR "bzip2" format.
    //          Print out the path to the zipped file in the console
    if (params.step == 7) {
        greeting_ch = Channel.of("Hello world!")
        out_ch = UPPERCASE(greeting_ch)
        zip_ch = ZIPFILE(out_ch, params.zip)
        zip_ch.view()
    }

    // Task 8 - Create a process that zips the file created in the UPPERCASE process in "zip", "gzip" AND "bzip2" format. Print out the paths to the zipped files in the console

    if (params.step == 8) {
        greeting_ch = Channel.of("Hello world!")
        out_ch = UPPERCASE(greeting_ch)
        zipped_ch = ZIPALL(out_ch)
        zipped_ch.view()

    }

    // Task 9 - Create a process that reads in a list of names and titles from a channel and writes them to a file.
    //          Store the file in the "results" directory under the name "names.tsv"

    if (params.step == 9) {
        in_ch = channel.of(
            ['name': 'Harry', 'title': 'student'],
            ['name': 'Ron', 'title': 'student'],
            ['name': 'Hermione', 'title': 'student'],
            ['name': 'Albus', 'title': 'headmaster'],
            ['name': 'Snape', 'title': 'teacher'],
            ['name': 'Hagrid', 'title': 'groundkeeper'],
            ['name': 'Dobby', 'title': 'hero'],
        )

        in_ch
            .collect()
            | WRITETOFILE
    }

}