#!/bin/bash
select opt in "${options[@]}" "Quit"
do

    if [[ -z $opt ]]; then
        echo "Didn't understand \"$REPLY\" "
        REPLY=
    else
        case "$opt" in

        docker)
            echo "Update Docker"
            break;;
        IdontExist)
            echo "Update IdontExist"
            break;;
        pushover)
            echo "Update mytest"
            break;;
        IdontexistEither)
            echo "Update IdontExistEither"
            break;;
        Quit)
            echo "Goodbye!"
            break;;
        *)
           echo "Invalid option <$opt>. Try another one."
           ;;
        esac
    fi
done
