function __fish_print_make_targets --argument-names directory file
    # Since we filter based on localized text, we need to ensure the
    # text will be using the correct locale.
    set -lx LC_ALL C

    if test -z "$directory"
        set directory '.'
    end

    if test -z "$file"
        for standard_file in $directory/{GNUmakefile,Makefile,makefile}
            if test -f $standard_file
                set file $standard_file
                break
            end
        end
    end

    set -l bsd_make
    if make -C $directory -pn >/dev/null ^/dev/null
        set bsd_make 0
    else
        set bsd_make 1
    end

    if test "$bsd_make" = 0
        # https://stackoverflow.com/a/26339924
        make -C "$directory" -f "$file" -pRrq : ^/dev/null | awk -v RS= -F: '/^# Files/,/^# Finished Make data base/ {if ($1 !~ "^[#.]") {print $1}}' ^/dev/null
    else
        make -C "$directory" -f "$file" -d g1 -rn >/dev/null ^| awk -F, '/^#\*\*\* Input graph:/,/^$/ {if ($1 !~ "^#... ") {gsub(/# /,"",$1); print $1}}' ^/dev/null
    end
end

