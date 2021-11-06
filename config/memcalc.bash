#!/bin/bash 
(set -o igncr) 2>/dev/null && set -o igncr; # this comment is required
set -$-ue${DEBUG+xv}

#######################################################################################################################
# This script processes the memory consumption of an application and prints it out to the console.
#
# usage:
#	memcalc.bash <READELFFILE> <AVAILABLEFLASH> <AVAILABLESRAM> <STARTFLASH> <STARTSRAM>
#
#######################################################################################################################

READELFFILE=$1              # file location of readelf output
AVAILABLEFLASH=$2           # Max available internal flash
AVAILABLESRAM=$3            # Max available internal SRAM
STARTFLASH=$4               # Start of internal flash
STARTSRAM=$5                # Start of internal SRAM

ENDFLASH=$((STARTFLASH + AVAILABLEFLASH))
ENDSRAM=$((STARTSRAM + AVAILABLESRAM))

# Gather the numbers
memcalc() {
    local internalFlash=0
    local internalSram=0

    printf "   ---------------------------------------------------- \n"
    printf "  | %-20s |  %-10s   |  %-10s | \n" 'Section Name' 'Address' 'Size'
    printf "   ---------------------------------------------------- \n"

    while IFS=$' \t\n\r' read -r line; do
        local lineArray=($line)
        local numElem=${#lineArray[@]}
        
        # Only look at potentially valid lines
        if [[ $numElem -ge 6 ]]; then
            # Section headers
            if [[ ${lineArray[0]} == "["* ]]; then
                local sectionElement=NULL
                local addrElement=00000000
                local sizeElement=000000
                for (( idx = 0 ; idx <= $numElem-4 ; idx = $idx+1 ));
                do
                    if [[ ${lineArray[$idx]} == *"]" ]]; then
                        sectionElement=${lineArray[$idx+1]}
                    fi
                    # Look for regions with SHF_ALLOC = A
                    arr0=${lineArray[idx]} arr1=${lineArray[idx+1]} arr2=${lineArray[idx+2]}                            # fix bad substitution error (Rolf)
                    if [[ ${#arr0} -eq 8 ]] && [[ ${#arr1} -eq 6 ]] && [[ ${#arr2} -ge 6 ]] && [[ ${#arr2} -le 7 ]]\
                       && [[ ${lineArray[$idx+4]} == *"A"* ]] ; then
                        addrElement=${lineArray[$idx]}
                        sizeElement=${lineArray[$idx+2]}
                    fi
                done
                # Only consider non-zero size sections
                if [[ $addrElement != "00000000" ]]; then
                    printf "  | %-20s |  0x%-10s |  %-10s | \n" $sectionElement $addrElement $((16#$sizeElement))
                    # Use the section headers for SRAM tally
                    if [[ "0x$addrElement" -ge "$STARTSRAM" ]] && [[ "0x$addrElement" -lt "$ENDSRAM" ]]; then
                        internalSram=$((internalSram+$((16#$sizeElement))))
                    fi
                fi
            # Program headers
            elif [[ ${lineArray[1]} == "0x"* ]] && [[ ${lineArray[2]} == "0x"* ]] && [[ ${lineArray[3]} == "0x"* ]] && [[ ${lineArray[4]} == "0x"* ]]\
                && [[ ${lineArray[3]} -ge "$STARTFLASH" ]] && [[ ${lineArray[3]} -lt "$ENDFLASH" ]]; then
                # Use the program headers for Flash tally
                internalFlash=$((internalFlash+${lineArray[4]}))
            fi
        fi
    done < "$READELFFILE"
    internalFlashPercent=$(($internalFlash * 100 / $AVAILABLEFLASH))
    internalRamPercent=$(($internalSram * 100 / $AVAILABLESRAM))
    internalFlashRemainder=$((($internalFlash * 1000 / $AVAILABLEFLASH) - ($internalFlashPercent * 10)))
    internalRamRemainder=$((($internalSram * 1000 / $AVAILABLESRAM) - ($internalRamPercent * 10)))
    printf "   -------------------------------------------------- \n\n"
    printf "  %-41s %-8s 0x%05x \n" 'Total Internal Flash (Available)' $AVAILABLEFLASH $AVAILABLEFLASH
    printf "  %-41s %-8s 0x%05x %5s.%s%% \n\n" 'Total Internal Flash (Utilized)' $internalFlash $internalFlash $internalFlashPercent $internalFlashRemainder
    printf "  %-41s %-8s 0x%05x \n" 'Total Internal SRAM (Available)' $AVAILABLESRAM $AVAILABLESRAM
    printf "  %-41s %-8s 0x%05x %5s.%s%% \n" 'Total Internal SRAM (Utilized)' $internalSram $internalSram $internalRamPercent $internalRamRemainder
}

memcalc