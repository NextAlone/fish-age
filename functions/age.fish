function age -d "Just to get next version tag on git"
    argparse -n age M/major m/minor p/patch -- $argv
    or return 1

    set -l latest_version

    if [ "$argv[1]" != "" ]
        set latest_version $argv[1]
    else
        set -l tags (git tag --sort=-creatordate | xargs -n 1000)
        set latest_version "v0.0.0"
        for tag in (string split ' ' $tags)
            set -l matches (string match -r '(\d+\.)*(\d+)\.(\d+)\.(\d+)(\.\S+)*' $tag)
            if test "$matches"
                set latest_version $tag
                break
            end
        end
    end

    set -l matches (string match -r '([vV]?)((\d+\.)*)(\d+)\.(\d+)\.(\d+)(\.[a-zA-Z][a-zA-Z0-9]*)*' $latest_version)

    set v_prefix $matches[2]
    set prefix $matches[3]
    if string match -q -r '\.' $matches[-1]
        set major $matches[-4]
        set minor $matches[-3]
        set patch $matches[-2]
        set suffix $matches[-1]
    else
        set major $matches[-3]
        set minor $matches[-2]
        set patch $matches[-1]
        set suffix ""
    end


    if set -lq _flag_patch _flag_p
        echo "$v_prefix$prefix$major.$minor.$(math $patch + 1)"
        return
    else if set -lq _flag_minor _flag_m
        echo "$v_prefix$prefix$major.$(math $minor + 1).0"
        return
    else if set -lq _flag_major _flag_M
        echo "$v_prefix$prefix$(math $major + 1).0.0"
        return
    else
        echo "$v_prefix$prefix$major.$minor.$patch$suffix"
        return
    end
end
